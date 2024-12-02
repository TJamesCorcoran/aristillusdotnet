# frozen_string_literal: true

# people have 0+ attribute-value associations
# attributes (keys) are in the db
class Key < ApplicationRecord
  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    ['name']
  end
end
