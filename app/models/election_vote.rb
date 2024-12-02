# frozen_string_literal: true

# A single vote cast by one user for one choice in an election
# e.g. "User TJIC voted for Trump in 2024"
class ElectionVote < ApplicationRecord
  belongs_to :user
  belongs_to :election_choice
  has_one :election, through: :election_choice
  belongs_to :delegated_clone, class_name: 'ElectionVote', optional: true

  validate :one_user_vote_per_elections

  def one_user_vote_per_elections
    other = ElectionVote.joins(:election_choice)
                        .where.not(id: id)
                        .where(user_id: user_id,
                               election_choice: { election_id: election_choice.election_id }).first
    return unless other

    errors.add(:election_vote, "this user has already voted in this election; other is ElectionVote.id = #{other.id}")
  end
end
