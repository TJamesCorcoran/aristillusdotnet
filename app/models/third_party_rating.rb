# frozen_string_literal: true

# records one particular rating entity's evaluation of one particular
#  person in one particular instance (e.g. NHLA in NHLA 2023 recording
#  Travis Corcoran as A+)
class ThirdPartyRating < ApplicationRecord
  belongs_to :person
  belongs_to :third_party_rating_instance
  belongs_to :third_party_rating_grade

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[]
  end
end
