# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VoteDelegation do
  describe 'with no entries' do
    let(:user) { create(:user) }
    let(:proxy_1) { create(:user) }
    let(:proxy_2) { create(:user) }
    let(:proxy_3) { create(:user) }

    let!(:vote_delegation_2) { create(:vote_delegation, user: user, rank: 2, delegate: proxy_2) }
    let!(:vote_delegation_1) { create(:vote_delegation, user: user, rank: 1, delegate: proxy_1) }
    let!(:vote_delegation_3) { create(:vote_delegation, user: user, rank: 3, delegate: proxy_3, live: false) }

    it 'excludes non-live delegations' do
      expect(user.vote_delegations.count).to eq(2)
    end

    it 'returns delegations in ranked order' do
      expect(user.vote_delegations[0].delegate).to eq(proxy_1)
      expect(user.vote_delegations[1].delegate).to eq(proxy_2)
    end
  end
end
