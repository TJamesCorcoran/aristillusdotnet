# frozen_string_literal: true

FactoryBot.define do
  sequence(:membership_names) { |n| "Membership tier #{n}" }

  factory :membership do
    name { generate(:membership_names) }
    description { 'description' }
    price { 10.00 }
  end
end
