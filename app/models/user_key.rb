# frozen_string_literal: true

# maps user to key
class UserKey < ApplicationRecord
  belongs_to :user
  belongs_to :key
end
