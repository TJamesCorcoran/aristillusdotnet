# frozen_string_literal: true

# a grade (e.g. A+) that an entity (e.g. NHLA) is in the habit of issuing.
#
# the platonic ideal of the GRADE , not a particular rating to a particular person.
class ThirdPartyRatingGrade < ApplicationRecord
  belongs_to :third_party_rating_entity
  has_many :third_party_rating, dependent: :destroy
end
