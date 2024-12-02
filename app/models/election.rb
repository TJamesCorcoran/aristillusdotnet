# frozen_string_literal: true

# election, e.g. POTUS 2024
class Election < ApplicationRecord
  belongs_to :tier
  has_many :election_choices, dependent: nil
  has_many :election_votes, through: :election_choices

  scope :open, -> { where(['open_datetime <= ? and close_datetime >= ?', DateTime.now, DateTime.now]) }
  scope :for_user, ->(user) { joins(:tier).where(tiers: { threshhold_low: ..user.cred }) }

  def finalize!
    raise 'already finalized' if finalized

    ActiveRecord::Base.transaction do
      users_eligible = tier.get_users # .with(:user => :vote_delegations)
      votes = election_votes # .with(:user => :vote_delegations)
      users_voting = votes.map(&:user)
      users_other = users_eligible - users_voting

      other_delegated = 0
      other_undelegated = 0

      users_other.each do |uo|
        # find the first delegate who cast a vote in this election
        vote_to_clone = nil
        uo.vote_delegations.detect do |vd|
          vote_to_clone = ElectionVote.joins(:election_choice)
                                      .where(user_id: vd.delegate_id,
                                             election_choice: { election_id: id }).first
        end
        if vote_to_clone
          ElectionVote.create!(user: uo,
                               election_choice: vote_to_clone.election_choice,
                               delegated_clone: vote_to_clone)
          other_delegated += 1
        else
          other_undelegated += 1
        end
      end

      # puts "users_voting = #{users_voting.count}"
      # puts "other_delegated = #{other_delegated}"
      # puts "other_undelegated = #{other_undelegated}"

      update!(finalized: true)
    end
    true
  end

  def vote_count
    election_votes.count_by(&:election_choice)
  end
end
