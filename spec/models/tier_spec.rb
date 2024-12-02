# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tier do
  describe 'with basic setup' do
    let!(:tier_founder) { create(:tier, name: 'Founder', threshhold_low: 100, threshhold_high: nil) }
    let!(:tier_patron)  { create(:tier, name: 'Patron',  threshhold_low: 80, threshhold_high: 99) }
    let!(:tier_sgt)     { create(:tier, name: 'Sgt',     threshhold_low: 50, threshhold_high: 79) }
    let!(:tier_newb)    { create(:tier, name: 'Newb',    threshhold_low: 20, threshhold_high: 49) }

    it 'scope works' do
      expect(described_class.for_credit_x(25).to_a).to eq([described_class.find_by(name: 'Newb')])
    end

    describe 'with basic users' do
      let!(:user_a) { create(:user, cred: 100) }
      let!(:user_b) { create(:user, cred: 50) }
      let!(:user_c) { create(:user, cred: 0) }

      it 'users() works' do
        expect(tier_newb.get_users.count).to eq(2)
        expect(tier_patron.get_users.count).to eq(1)
      end
    end
  end
end
