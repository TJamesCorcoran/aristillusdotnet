# frozen_string_literal: true

# An entity (e.g. NHLA) that issues ratings to people
#
class ThirdPartyRatingEntity < ApplicationRecord
  has_many :third_party_rating_instances, dependent: :destroy
  has_many :third_party_rating_grades, dependent: :destroy

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name]
  end
end
