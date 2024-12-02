# frozen_string_literal: true

# User X can delegate his franchise to user Y (actually, to a long
# chain of delegates).  If the user doesn't vote, his first delegate's
# vote is cloned for him.  If the first delegate doesn't vote, X's
# vote is delegated to his second choice, etc.
#
class VoteDelegation < ApplicationRecord
  belongs_to :user
  belongs_to :delegate, class_name: 'User'
  scope :live, -> { where(live: true) }

  validates :rank, uniqueness: { scope: [:user] }
end
