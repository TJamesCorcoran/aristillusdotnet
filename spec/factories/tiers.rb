# frozen_string_literal: true

FactoryBot.define do
  sequence(:tier_name) { |n| "Tier #{n}" }

  factory :tier do
    name { generate(:tier_name) }
    description { generate(:tier_name) }
    threshhold_low { 1 }
    threshhold_high { nil }
  end
end
