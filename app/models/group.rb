# frozen_string_literal: true

# users belongs to groups
class Group < ApplicationRecord
  belongs_to :owner, class_name: 'User', foreign_key: :user_id, inverse_of: :administered_groups
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  validates :name, uniqueness: true

  def self.ransackable_associations(_auth_object = nil)
    ['owner'] # "users"
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name description owner_id]
  end
end
