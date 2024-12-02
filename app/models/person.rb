# frozen_string_literal: true

# IRL person ; account details in 'user'
class Person < ApplicationRecord
  belongs_to :address, optional: true
  has_one :user, dependent: nil
  has_many :third_party_ratings, dependent: :destroy

  validates :name, uniqueness: true

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name dob male phone id]
  end

  def third_party_rating_scores
    third_party_ratings.map(&:third_party_rating_grade).pluck(:value)
  end
end
