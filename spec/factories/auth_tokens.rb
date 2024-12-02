# frozen_string_literal: true

FactoryBot.define do
  factory :auth_token do
    # association :user, strategy: :build
    # user { nil }
    authentication_token { Devise.friendly_token }
    last_used { DateTime.now }
    ip { '8.8.8.8' }
    useragent { 'brave-web-browser' }
  end
end
