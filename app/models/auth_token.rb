# frozen_string_literal: true

# token based authentication for users
class AuthToken < ApplicationRecord
  belongs_to :user

  validates :ip, uniqueness: { scope: :user }

  def still_valid?
    (last_used + Rails.configuration.token_lifetime) > DateTime.now
  end
end
