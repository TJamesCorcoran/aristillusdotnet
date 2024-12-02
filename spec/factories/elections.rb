# frozen_string_literal: true

FactoryBot.define do
  sequence(:election_name) { |n| "Election #{n}" }

  factory :election do
    name { generate(:election_name) }
    description { 'This is an election' }
    tier { Tier.first || create(:tier) }
    open_datetime { DateTime.now }
    close_datetime { DateTime.now + 7.days }
  end
end
