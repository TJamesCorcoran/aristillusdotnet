# frozen_string_literal: true

# online account ; IRL human details in 'person'
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  #  acts_as_token_authenticatable

  devise :database_authenticatable, :confirmable, :recoverable, :rememberable, :validatable

  belongs_to :person, optional: true
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members
  has_many :user_keys, inverse_of: :user, dependent: :destroy

  has_many :cred_logs, inverse_of: :user, dependent: :destroy

  has_many :vote_delegations, -> { where(live: true).order('rank ASC') }, inverse_of: :user, dependent: :destroy
  has_many :delegates, class_name: 'User', through: :vote_delegations, dependent: :destroy

  has_many :administered_groups, class_name: 'Group', dependent: nil

  has_many :auth_tokens, dependent: :destroy

  validates :name, uniqueness: { allow_nil: true }

  # before_save :ensure_authentication_token

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[name email person_id]
  end

  def key_vals
    user_keys.to_h { |uk| [uk.key.name, uk.value] }
  end

  def admin?
    groups.where(name: 'Admin').any?
  end

  def get_cred
    cred_logs.inject(0) { |sum, cl| sum + cl.cred }
  end

  def get_tier
    Tier.for_credit_x(get_cred).first
  end
end
