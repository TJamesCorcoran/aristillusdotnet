# frozen_string_literal: true

FactoryBot.define do
  sequence(:user_email) { |n| "user_#{n}@example.com" }
  sequence(:user_name) { |n| "user_#{n}" }

  factory :user do
    # association :auth_tokens, strategy: :build
    name { generate(:user_name) }
    email { generate(:user_email) }
    password { 'password' }
    confirmed_at { DateTime.now }
  end

  #  after(:build) do |user, evaluator|
  #    create(:auth_token, user_id: user.id)
  #  end
end
