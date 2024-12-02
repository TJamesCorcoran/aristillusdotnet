# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Memberships' do
  let!(:user) { create(:user) }
  let!(:membership_base) { create(:membership, name: 'base', price: 10) }
  let!(:membership_silver) { create(:membership, name: 'silver', price: 20) }
  let!(:membership_gold) { create(:membership, name: 'gold', price: 50) }

  before do
    post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
    response.parsed_body
  end

  describe 'GET /index' do
    it 'returns all memberships' do
      get '/api/v1/memberships', as: :json, params: { user_email: user.email,
                                                      user_token: user.auth_tokens.first.authentication_token }

      json_response = response.parsed_body

      expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
      expect(json_response['data']).to eq([{ 'id' => membership_base.id,
                                             'name' => 'base',
                                             'description' => 'description',
                                             'price' => '10.0' },
                                           { 'id' => membership_silver.id,
                                             'name' => 'silver',
                                             'description' => 'description',
                                             'price' => '20.0' },
                                           { 'id' => membership_gold.id,
                                             'name' => 'gold',
                                             'description' => 'description',
                                             'price' => '50.0' }])
    end
  end
end
