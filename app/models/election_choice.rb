# frozen_string_literal: true

# Election Choice represents one of 2+ choices in an election.
# e.g.
#   Election: POTUS 2024
#   ElectionChoice: Trump
#   ElectionChoice: Kamala
class ElectionChoice < ApplicationRecord
  belongs_to :election
  has_many :election_votes, dependent: nil
end
