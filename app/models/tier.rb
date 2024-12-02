# frozen_string_literal: true

# Users are ranked into tiers based on social credit score.
#
class Tier < ApplicationRecord
  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name description]
  end

  scope :for_credit_x, lambda { |x|
    where(['(threshhold_low is null or (? >= threshhold_low)) and
            (threshhold_high is null or (? <= threshhold_high))', x, x])
  }

  def get_users
    User.where(cred: threshhold_low..)
  end
end
