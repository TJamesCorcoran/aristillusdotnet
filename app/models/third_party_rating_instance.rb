# frozen_string_literal: true

# An instance of a rating (e.g. A+) issued by a rating entity
# (e.g. NHLA) in a particular rating instance (e.g. 2023) to a
# particular user (e.g. Jason Osborne)
#
class ThirdPartyRatingInstance < ApplicationRecord
  belongs_to :third_party_rating_entity
  has_many :third_party_ratings, dependent: :destroy

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[instance]
  end
end
