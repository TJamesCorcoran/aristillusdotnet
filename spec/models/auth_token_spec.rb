# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthToken do
  describe 'ip addr is unique per user' do
    let!(:user_1) { create(:user) }
    let!(:user_2) { create(:user) }

    let!(:token_0) { create(:auth_token, user: user_1, ip: '1.1.1.1') }
    let(:token_1) { build(:auth_token, user: user_1, ip: '1.1.1.1') }
    let(:token_2) { build(:auth_token, user: user_1, ip: '2.2.2.2') }
    let(:token_3) { build(:auth_token, user: user_2, ip: '1.1.1.1') }

    it 'uniqueness is enforced as per design' do
      expect(token_0.valid?).to be(true)
      expect(token_1.valid?).to be(false)
      expect(token_2.valid?).to be(true)
      expect(token_3.valid?).to be(true)
    end
  end
end
