# frozen_string_literal: true

FactoryBot.define do
  factory :vote_delegation do
    user
    delegate factory: %i[user]
    rank { 1 }
    live { true }
  end
end
