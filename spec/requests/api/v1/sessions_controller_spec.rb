# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::SessionsControllerSpec' do
  describe 'sign_in' do
    describe 'with correct params' do
      let!(:user) { create(:user) }

      before do
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'JSON body response contains expected attributes and creates a new token in DB' do
        json_response = response.parsed_body
        expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
        expect(json_response['data'].keys.map(&:to_sym)).to include(:token)

        expect(user.auth_tokens.count).to eq(1)
      end

      it 'one token is issued for each IP addr' do
        expect(user.auth_tokens.count).to eq(1)

        self.remote_addr = '1.1.1.1'
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        expect(user.auth_tokens.count).to eq(2)

        self.remote_addr = '2.2.2.2'
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        expect(user.auth_tokens.count).to eq(3)

        # same as first IP addr; do not create a new one; remain at 3 total
        #
        self.remote_addr = '127.0.0.1'
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        expect(user.auth_tokens.count).to eq(3)
      end

      it 'token allows access to other actions' do
        json_response = response.parsed_body
        token = json_response[:data][:token]

        get '/api/v1/elections/list_open_elections',
            as: :json,
            params: { id: user.id,
                      user_email: user.email,
                      user_token: token }
        expect(response.parsed_body.keys.map(&:to_sym)).to eq(%i[success data])
        expect(response.parsed_body[:success]).to be(true)
      end
    end

    describe 'with good params and time travel' do
      let!(:user) { create(:user) }

      it 'fails if token is expired' do
        time = DateTime.parse('2019-01-01 T12:00:00 -05:00')

        token = nil
        Timecop.travel(time) do
          post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
          json_response = response.parsed_body
          expect(response.parsed_body[:success]).to be(true)

          token = json_response[:data][:token]
          get '/api/v1/elections/list_open_elections',
              as: :json,
              params: { id: user.id,
                        user_email: user.email,
                        user_token: token }
          expect(response.parsed_body[:success]).to be(true)
        end

        # jump 6 days into the future (6 days total from sigin in) - token still valid
        #
        time += 6.days
        Timecop.travel(time) do
          get '/api/v1/elections/list_open_elections',
              as: :json,
              params: { id: user.id,
                        user_email: user.email,
                        user_token: token }
          expect(response.parsed_body[:success]).to be(true)
        end

        # jump 6 days into the future (12 days total from sigin in) - token still valid
        #
        time += 6.days
        Timecop.travel(time) do
          get '/api/v1/elections/list_open_elections',
              as: :json,
              params: { id: user.id,
                        user_email: user.email,
                        user_token: token }
          expect(response.parsed_body[:success]).to be(true)
        end

        # jump 8 days into the future - token expired
        #
        time += 8.days
        Timecop.travel(time) do
          get '/api/v1/elections/list_open_elections',
              as: :json,
              params: { id: user.id,
                        user_email: user.email,
                        user_token: token }
          expect(response.parsed_body[:success]).to be(false)
          expect(response.parsed_body[:message]).to eq('token expired')
        end
      end
    end

    describe 'with bad user' do
      before do
        post '/api/v1/users', params: { foo: 'fred2@fred.com' }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'JSON body response contains expected attributes' do
        json_response = response.parsed_body
        expect(json_response).to eq({ 'success' => false, 'error' => "Validation failed: Email can't be blank" })
      end
    end

    describe 'with good user but corrupted token' do
      let!(:user) { create(:user) }

      it 'fails' do
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        json_response = response.parsed_body
        expect(response.parsed_body[:success]).to be(true)

        token = "#{json_response[:data][:token]}_CORRUPTED"
        get '/api/v1/elections/list_open_elections',
            as: :json,
            params: { id: user.id,
                      user_email: user.email,
                      user_token: token }
        expect(response.parsed_body[:success]).to be(false)
        expect(response.parsed_body[:message]).to eq('token not found for this IP')
      end
    end

    describe 'with good user but token from wrong IP addr' do
      let!(:user) { create(:user) }

      it 'fails' do
        # sign in from IP addr A
        #
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        json_response = response.parsed_body
        expect(response.parsed_body[:success]).to be(true)

        # other actions work from same IP addr
        #
        token = json_response[:data][:token]
        get '/api/v1/elections/list_open_elections',
            as: :json,
            params: { id: user.id,
                      user_email: user.email,
                      user_token: token }
        expect(response.parsed_body[:success]).to be(true)

        # ...but same token fails if used from another IP
        #
        self.remote_addr = '1.1.1.1'
        get '/api/v1/elections/list_open_elections',
            as: :json,
            params: { id: user.id,
                      user_email: user.email,
                      user_token: token }
        expect(response.parsed_body[:success]).to be(false)
        expect(response.parsed_body[:message]).to eq('token not found for this IP')
      end
    end
  end
end
