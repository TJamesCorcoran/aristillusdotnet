# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ElectionVote do
  describe 'create some models' do
    let(:election) { create(:election) }
    let!(:choice_a) { create(:election_choice, election: election) }
    let!(:choice_b) { create(:election_choice, election: election) }

    let!(:user) { create(:user) }

    describe 'with one user voting twice (illegal)' do
      let!(:vote_a) { build(:election_vote, user: user, election_choice: choice_a) }
      let!(:vote_b) { build(:election_vote, user: user, election_choice: choice_a) }
      let!(:vote_c) { build(:election_vote, user: user, election_choice: choice_b) }

      it 'catches the error' do
        # vote_a is valid, before and after save
        expect(vote_a.valid?).to be(true)
        vote_a.save!
        expect(vote_a.valid?).to be(true)

        # vote_b (same user, same election, same choice) is invalid
        expect(vote_b.valid?).to be(false)

        # vote_b (same user, same election, different choice) is invalid
        expect(vote_c.valid?).to be(false)
      end
    end
  end
end
