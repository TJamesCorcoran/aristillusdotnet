# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Election do
  describe 'create some models' do
    describe 'scopes' do
      let(:tier_0) { create(:tier, threshhold_low: 0) }
      let(:tier_100) { create(:tier, threshhold_low: 100) }
      let(:tier_200) { create(:tier, threshhold_low: 200) }

      let!(:election_before_tier0) do
        create(:election,
               open_datetime: DateTime.parse('2016-01-01'),
               close_datetime: DateTime.parse('2016-12-31'),
               tier: tier_0)
      end
      let!(:election_now_tier100) do
        create(:election,
               open_datetime: DateTime.parse('2017-01-01'),
               close_datetime: DateTime.parse('2017-12-31'),
               tier: tier_100)
      end
      let!(:election_later_tier200) do
        create(:election,
               open_datetime: DateTime.parse('2018-01-01'),
               close_datetime: DateTime.parse('2018-12-31'),
               tier: tier_200)
      end
      let(:user) { create(:user, cred: 105) }

      it '.open() scope works' do
        # puts "Election.all = #{Election.all.inspect}"
        Timecop.travel('2017-06-01 5pm') do
          expect(described_class.open.to_a).to eq([election_now_tier100])
        end
      end

      it '.for_user() scope works' do
        expect(described_class.for_user(user).to_a).to eq([election_before_tier0, election_now_tier100])
      end

      it 'both scopes work together' do
        Timecop.travel('2016-06-01 5pm') do
          expect(described_class.open.for_user(user).to_a).to eq([election_before_tier0])
        end
        Timecop.travel('2017-06-01 5pm') do
          expect(described_class.open.for_user(user).to_a).to eq([election_now_tier100])
        end
        Timecop.travel('2018-06-01 5pm') do
          expect(described_class.open.for_user(user).to_a).to eq([])
        end
      end
    end

    describe 'relations' do
      let(:election) { create(:election) }
      let!(:choice_a) { create(:election_choice, election: election, name: 'choice A') }
      let!(:choice_b) { create(:election_choice, election: election, name: 'choice B') }

      let!(:user_a) { create(:user) }
      let!(:user_b) { create(:user) }

      describe 'with no votes' do
        it 'has right number of votes and choices' do
          expect(election.election_votes.count).to eq(0)
          expect(election.election_choices.count).to eq(2)
        end
      end

      describe 'with 1 vote' do
        let!(:vote_a) { create(:election_vote, user: user_a, election_choice: choice_a) }

        it 'has right number of votes and choices' do
          expect(election.election_votes.count).to eq(1)
          expect(election.election_choices.count).to eq(2)
        end
      end

      describe 'with 2 votes' do
        let!(:vote_a) { create(:election_vote, user: user_a, election_choice: choice_a) }
        let!(:vote_b) { create(:election_vote, user: user_b, election_choice: choice_b) }

        it 'has right number of votes and choices' do
          expect(election.election_votes.count).to eq(2)
          expect(election.election_choices.count).to eq(2)
        end
      end

      describe 'with 2 votes, + 1 vote for some other election' do
        let(:election_2) { create(:election) }
        let(:election_2_choice) { create(:election_choice, election: election_2) }

        let!(:vote_a) { create(:election_vote, user: user_a, election_choice: choice_a) }
        let!(:vote_b) { create(:election_vote, user: user_b, election_choice: choice_b) }
        let!(:vote_c) { create(:election_vote, user: user_b, election_choice: election_2_choice) }

        it 'has right number of votes and choices' do
          expect(election.election_votes.count).to eq(2)
        end
      end
    end

    describe 'finalize elections' do
      let(:tier) { create(:tier, threshhold_low: 0) }

      let(:election) { create(:election, tier: tier) }
      let!(:choice_a) { create(:election_choice, election: election) }
      let!(:choice_b) { create(:election_choice, election: election) }

      let!(:user_a) { create(:user, cred: 100) }
      let!(:user_b) { create(:user, cred: 100) }

      describe '1 vote each, 2 total' do
        let!(:vote_a) { create(:election_vote, user: user_a, election_choice: choice_a) }
        let!(:vote_b) { create(:election_vote, user: user_b, election_choice: choice_b) }

        it 'finalizes correctly' do
          ret = election.finalize!
          expect(ret).to be(true)
          expect(election.finalized).to be(true)
          expect(election.election_votes.count).to eq(2)
        end
      end

      describe '1 vote, no delegates, 1 total' do
        let!(:vote_a) { create(:election_vote, user: user_a, election_choice: choice_a) }

        it 'finalizes correctly' do
          ret = election.finalize!
          expect(ret).to be(true)
          expect(election.finalized).to be(true)
          expect(election.election_votes.count).to eq(1)
        end
      end

      describe '1 actual vote, 1 delegation = 2 votes total' do
        let!(:vote_a) { create(:election_vote, user: user_a, election_choice: choice_a) }
        let!(:vote_delegation) { create(:vote_delegation, user: user_b, delegate: user_a, rank: 1) }

        it 'finalizes correctly' do
          ret = election.finalize!
          expect(ret).to be(true)
          expect(election.finalized).to be(true)
          expect(election.election_votes.count).to eq(2)
          expect(election.election_votes.where(delegated_clone_id: nil).count).to eq(1)
          expect(election.election_votes.where.not(delegated_clone_id: nil).count).to eq(1)
        end
      end

      describe '1 actual vote, 5 delegations (4 empty) = 2 votes total' do
        let!(:vote_a) { create(:election_vote, user: user_a, election_choice: choice_a) }

        let!(:vote_delegation_1) { create(:vote_delegation, user: user_b, rank: 1) }
        let!(:vote_delegation_2) { create(:vote_delegation, user: user_b, rank: 2) }
        let!(:vote_delegation_3) { create(:vote_delegation, user: user_b, rank: 3) }
        let!(:vote_delegation_4) { create(:vote_delegation, user: user_b, rank: 4) }
        let!(:vote_delegation_5) { create(:vote_delegation, user: user_b, delegate: user_a, rank: 5) }

        it 'finalizes correctly' do
          ret = election.finalize!
          expect(ret).to be(true)
          expect(election.finalized).to be(true)
          expect(election.election_votes.count).to eq(2)
          expect(election.election_votes.where(delegated_clone_id: nil).count).to eq(1)

          expect(election.election_votes.where.not(delegated_clone_id: nil).count).to eq(1)

          vote_direct = election.election_votes.where(delegated_clone_id: nil).first
          vote_indirect = election.election_votes.where.not(delegated_clone_id: nil).first

          expect(vote_indirect.delegated_clone).to eq(vote_direct)
        end
      end
    end
  end
end
