# frozen_string_literal: true

FactoryBot.define do
  factory :election_vote do
    user
    live { true }
    delegated_clone { nil }
  end
end
