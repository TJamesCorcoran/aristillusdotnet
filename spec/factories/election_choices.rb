# frozen_string_literal: true

FactoryBot.define do
  sequence(:election_choice_names) { |n| "Choice #{n}" }

  factory :election_choice do
    name { generate(:election_choice_names) }
  end
end
