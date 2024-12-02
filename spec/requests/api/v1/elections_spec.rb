# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Elections' do
  before do
    post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
  end

  describe 'GET #list_open_elections' do
    describe 'with correct params' do
      let(:tier_5) { create(:tier, threshhold_low: 5) }
      let(:tier_100) { create(:tier, threshhold_low: 100) }
      let(:tier_200) { create(:tier, threshhold_low: 200) }

      let!(:election_1) { create(:election, name: 'Election 1', tier: tier_5) }
      let!(:election_1_a) { create(:election_choice, name: '1 A', election: election_1) }
      let!(:election_1_b) { create(:election_choice, name: '1 B', election: election_1) }
      let!(:election_1_c) { create(:election_choice, name: '1 C', election: election_1) }

      let!(:election_2) { create(:election, name: 'Election 2', tier: tier_100) }
      let!(:election_2_a) { create(:election_choice, name: '2 A', election: election_2) }
      let!(:election_2_b) { create(:election_choice, name: '2 B', election: election_2) }
      let!(:election_2_c) { create(:election_choice, name: '2 C', election: election_2) }

      let!(:election_3) { create(:election, name: 'Election 3', tier: tier_200) }
      let!(:election_3_a) { create(:election_choice, name: '3 A', election: election_3) }
      let!(:election_3_b) { create(:election_choice, name: '3 B', election: election_3) }

      before do
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
      end

      describe 'user has 0 cred and no elections' do
        let!(:user) { create(:user, cred: 0) }

        it 'JSON body response contains expected attributes' do
          # post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
          # json_response = response.parsed_body
          get '/api/v1/elections/list_open_elections',
              as: :json,
              params: { id: user.id,
                        user_email: user.email,
                        user_token: user.auth_tokens.first.authentication_token }
          json_response = response.parsed_body

          expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
          expect(json_response['data'].keys.map(&:to_sym)).to eq([:elections])
          expect(json_response['data']['elections']).to eq([])
        end
      end

      describe 'user has 5 cred and 1 elections' do
        let(:user) { create(:user, cred: 5) }

        before do
          post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        end

        it 'JSON body response contains expected attributes' do
          get '/api/v1/elections/list_open_elections',
              as: :json,
              params: { id: user.id,
                        user_email: user.email,
                        user_token: user.auth_tokens.first.authentication_token }
          json_response = response.parsed_body

          expect(json_response.keys.map(&:to_sym)).to include(:success,
                                                              :data)
          expect(json_response['data'].keys.map(&:to_sym)).to eq([:elections])
          expect(json_response['data']['elections'].size).to eq(1)
          expect(json_response['data']['elections'][0].keys.map(&:to_sym)).to eq(%i[id
                                                                                    name
                                                                                    description
                                                                                    open_datetime
                                                                                    close_datetime
                                                                                    choices
                                                                                    my_vote])
          expect(json_response['data']['elections'][0]['name']).to eq('Election 1')
          expect(json_response['data']['elections'][0]['my_vote']).to be_nil
        end

        describe '...and he voted in the 1 election' do
          let!(:election_vote) do
            create(:election_vote,
                   user: user, election_choice: election_1_a)
          end

          it 'shows existing vote' do
            get '/api/v1/elections/list_open_elections',
                params: { id: user.id, user_email: user.email,
                          user_token: user.auth_tokens.first.authentication_token }
            json_response = response.parsed_body

            expect(json_response['data']['elections'][0]['my_vote'].keys.map(&:to_sym)).to eq(%i[choice_id
                                                                                                 choice_name])
            expect(json_response['data']['elections'][0]['my_vote']['choice_id']).to eq(election_1_a.id)
            expect(json_response['data']['elections'][0]['my_vote']['choice_name']).to eq(election_1_a.name)
          end
        end
      end

      describe 'user has 100 cred and 2 elections' do
        let(:user) { create(:user, cred: 100) }

        before do
          post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        end

        it 'JSON body response contains expected attributes' do
          get '/api/v1/elections/list_open_elections',
              params: { id: user.id, user_email: user.email,
                        user_token: user.auth_tokens.first.authentication_token }
          json_response = response.parsed_body

          expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
          expect(json_response['data'].keys.map(&:to_sym)).to eq([:elections])
          expect(json_response['data']['elections'].size).to eq(2)
          expect(json_response['data']['elections'][0]['name']).to eq('Election 1')
          expect(json_response['data']['elections'][1]['name']).to eq('Election 2')
          expect(json_response['data']['elections'][0]['my_vote']).to be_nil
        end

        describe '...and he voted in both elections' do
          let!(:election_vote_1) { create(:election_vote, user: user, election_choice: election_1_a) }
          let!(:election_vote_2) { create(:election_vote, user: user, election_choice: election_2_b) }

          it 'shows existing vote' do
            get '/api/v1/elections/list_open_elections',
                params: { id: user.id, user_email: user.email,
                          user_token: user.auth_tokens.first.authentication_token }
            json_response = response.parsed_body

            expect(json_response['data']['elections'][0]['my_vote'].keys.map(&:to_sym)).to eq(%i[choice_id
                                                                                                 choice_name])

            expect(json_response['data']['elections'][0]['my_vote']['choice_id']).to eq(election_1_a.id)
            expect(json_response['data']['elections'][0]['my_vote']['choice_name']).to eq(election_1_a.name)

            expect(json_response['data']['elections'][1]['my_vote'].keys.map(&:to_sym)).to eq(%i[choice_id
                                                                                                 choice_name])

            expect(json_response['data']['elections'][1]['my_vote']['choice_id']).to eq(election_2_b.id)
            expect(json_response['data']['elections'][1]['my_vote']['choice_name']).to eq(election_2_b.name)
          end
        end
      end

      describe 'user has 500 cred and 3 elections' do
        let(:user) { create(:user, cred: 500) }

        before do
          post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
        end

        it 'JSON body response contains expected attributes' do
          get '/api/v1/elections/list_open_elections',
              params: { id: user.id, user_email: user.email,
                        user_token: user.auth_tokens.first.authentication_token }
          json_response = response.parsed_body

          expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
          expect(json_response['data'].keys.map(&:to_sym)).to eq([:elections])
          expect(json_response['data']['elections'].size).to eq(3)
          expect(json_response['data']['elections'][0]['name']).to eq('Election 1')
          expect(json_response['data']['elections'][0]['my_vote']).to be_nil

          expect(json_response['data']['elections'][1]['name']).to eq('Election 2')
          expect(json_response['data']['elections'][0]['my_vote']).to be_nil

          expect(json_response['data']['elections'][2]['name']).to eq('Election 3')
          expect(json_response['data']['elections'][0]['my_vote']).to be_nil
        end

        describe '...and he voted in 1st and third elections' do
          let!(:election_vote_1) { create(:election_vote, user: user, election_choice: election_1_a) }
          let!(:election_vote_3) { create(:election_vote, user: user, election_choice: election_3_b) }

          it 'shows existing vote' do
            get '/api/v1/elections/list_open_elections',
                params: { id: user.id, user_email: user.email,
                          user_token: user.auth_tokens.first.authentication_token }
            json_response = response.parsed_body

            expect(json_response['data']['elections'].size).to eq(3)

            expect(json_response['data']['elections'][0]['name']).to eq('Election 1')
            expect(json_response['data']['elections'][0]['my_vote'].keys.map(&:to_sym)).to eq(%i[choice_id
                                                                                                 choice_name])
            expect(json_response['data']['elections'][0]['my_vote']['choice_id']).to eq(election_1_a.id)
            expect(json_response['data']['elections'][0]['my_vote']['choice_name']).to eq(election_1_a.name)

            expect(json_response['data']['elections'][1]['name']).to eq('Election 2')
            expect(json_response['data']['elections'][1]['my_vote']).to be_nil

            expect(json_response['data']['elections'][2]['name']).to eq('Election 3')
            expect(json_response['data']['elections'][2]['my_vote'].keys.map(&:to_sym)).to eq(%i[choice_id
                                                                                                 choice_name])
            expect(json_response['data']['elections'][2]['my_vote']['choice_id']).to eq(election_3_b.id)
            expect(json_response['data']['elections'][2]['my_vote']['choice_name']).to eq(election_3_b.name)
          end
        end
      end
    end
  end

  describe 'POST #vote_in_election' do
    describe 'with correct params' do
      let(:tier_5) { create(:tier, threshhold_low: 5) }
      let(:tier_100) { create(:tier, threshhold_low: 100) }
      let(:tier_200) { create(:tier, threshhold_low: 200) }

      let!(:election_1) { create(:election, name: 'Election 1', tier: tier_5) }
      let!(:election_1_a) { create(:election_choice, name: '1 A', election: election_1) }
      let!(:election_1_b) { create(:election_choice, name: '1 B', election: election_1) }
      let!(:election_1_c) { create(:election_choice, name: '1 C', election: election_1) }

      let!(:election_2) { create(:election, name: 'Election 2', tier: tier_100) }
      let!(:election_2_a) { create(:election_choice, name: '2 A', election: election_2) }
      let!(:election_2_b) { create(:election_choice, name: '2 B', election: election_2) }
      let!(:election_2_c) { create(:election_choice, name: '2 C', election: election_2) }

      let!(:election_3) { create(:election, name: 'Election 3', tier: tier_200) }
      let!(:election_3_a) { create(:election_choice, name: '3 A', election: election_3) }
      let!(:election_3_b) { create(:election_choice, name: '3 B', election: election_3) }

      before do
        post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
      end

      describe 'user can vote in Election 1, hasnt yet' do
        let(:user) { create(:user, cred: 1000) }

        it 'records his vote correctly' do
          # vote once
          #
          #
          post '/api/v1/elections/vote_in_election', params: { id: user.id,
                                                               user_email: user.email,
                                                               user_token: user.auth_tokens.first.authentication_token,
                                                               election_id: election_1.id,
                                                               choice_id: election_1_a.id }
          json_response = response.parsed_body

          expect(json_response['success']).to be(true)
          expect(json_response['message']).to eq('created vote')

          ev = ElectionVote.joins(:election_choice).find_by(['user_id = ? and election_choices.election_id = ?',
                                                             user.id, election_1.id])
          expect(ev.election_choice).to eq(election_1_a)

          # change vote
          #
          #
          post '/api/v1/elections/vote_in_election', params: { id: user.id,
                                                               user_email: user.email,
                                                               user_token: user.auth_tokens.first.authentication_token,
                                                               election_id: election_1.id,
                                                               choice_id: election_1_b.id }
          json_response = response.parsed_body

          expect(json_response['success']).to be(true)
          expect(json_response['message']).to eq('updated existing vote')

          ev = ElectionVote.joins(:election_choice).find_by(['user_id = ? and election_choices.election_id = ?',
                                                             user.id, election_1.id])
          expect(ev.election_choice).to eq(election_1_b)
        end
      end
    end
  end
end
