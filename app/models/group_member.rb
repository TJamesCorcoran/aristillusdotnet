# frozen_string_literal: true

# users belongs to groups.  A join table.
class GroupMember < ApplicationRecord
  belongs_to :user
  belongs_to :group
end
