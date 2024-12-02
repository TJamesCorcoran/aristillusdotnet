# frozen_string_literal: true

# physical address of person
class Address < ApplicationRecord
  has_one :person, dependent: :destroy
end
