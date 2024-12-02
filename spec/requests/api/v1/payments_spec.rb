# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Payments' do
  describe 'POST /create_subscription' do
    let!(:user) { create(:user) }
    let!(:payment_id) do
      pm = Stripe::PaymentMethod.create({
                                          type: 'card',
                                          card: {
                                            token: 'tok_visa'
                                            # number: '4242 4242 4242 4242',
                                            # exp_month: 12,
                                            # exp_year: 2099,
                                            # cvc: '123'
                                          },
                                          billing_details: { name: 'John Doe' }
                                        })
      pm['id']
    end

    let!(:membership) { create(:membership) }

    before do
      post '/api/v1/sign_in', as: :json, params: { user_email: user.email, user_password: user.password }
      response.parsed_body
    end

    it 'returns http success' do
      post '/api/v1/payments/create_subscription',
           as: :json,
           params: { user_email: user.email,
                     user_token: user.auth_tokens.first.authentication_token,
                     payment_method_id: payment_id,
                     membership_id: membership.id }
      json_response = response.parsed_body
      expect(response).to have_http_status(:success)
      expect(json_response.keys.map(&:to_sym)).to include(:success, :data)
      expect(json_response['data'].keys.map(&:to_sym)).to include(:client_secret)
    end
  end
end
