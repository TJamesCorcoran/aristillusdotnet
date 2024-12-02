# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::UsersControllerTests' do
  describe 'user_ping' do
    before do
      get '/api/v1/users/ping', as: :json
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has the right data' do
      json_response = response.parsed_body

      expect(json_response[:success]).to be(true)
      expect(json_response[:message]).to eq('users ping command worked')
    end
  end

  describe 'user_ping_auth' do
    let!(:user) { create(:user, cred: 0) }

    before do
      post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
      get '/api/v1/users/ping_auth', as: :json,
                                     params: { user_email: user.email,
                                               user_token: user.auth_tokens.first.authentication_token }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has the right data' do
      json_response = response.parsed_body

      expect(json_response[:success]).to be(true)
      expect(json_response[:message]).to eq('users ping_auth command worked')
    end
  end

  describe 'GET #verify' do
    describe 'with valid token' do
      before do
        token = 'G3Rrhi-XEnPFC3P-H4by'
        user = User.create!(email: 'fred@gmail.com', password: 'password', confirmation_token: token)
        assert(user.confirmed_at.nil?)
        post '/api/v1/users/verify', params: { token: token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'JSON body response contains expected attributes' do
        json_response = response.parsed_body
        expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
        expect(json_response['data'].keys.map(&:to_sym)).to include(:id, :name, :email, :person_id)

        # make sure that the confirmation actually happened
        assert(User.find_by(email: 'fred@gmail.com').confirmed_at)
      end
    end

    describe 'with bad token' do
      before do
        token = 'xxx'
        post '/api/v1/users/verify', params: { token: token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'JSON body response contains expected attributes' do
        json_response = response.parsed_body
        expect(json_response).to eq({ 'success' => false, 'error' => 'user not found with token xxx' })
      end
    end
  end

  describe 'GET #get_reputation' do
    describe 'with valid id' do
      let!(:user) { create(:user, cred: 0) }

      before do
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }

        get '/api/v1/users/get_reputation',
            params: { id: user.id, user_email: user.email,
                      user_token: user.auth_tokens.first.authentication_token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'JSON body response contains expected attributes' do
        json_response = response.parsed_body
        expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
        expect(json_response['data'].keys.map(&:to_sym)).to include(:id, :reputation)
      end
    end

    describe 'with bad id' do
      let!(:user) { create(:user, cred: 0) }

      before do
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }

        get '/api/v1/users/get_reputation',
            params: { id: 999, user_email: user.email,
                      user_token: user.auth_tokens.first.authentication_token }
      end

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'JSON body response contains expected attributes' do
        json_response = response.parsed_body
        expect(json_response).to eq({ 'success' => false, 'error' => 'user not found' })
      end
    end
  end
end
