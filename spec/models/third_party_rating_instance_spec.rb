# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ThirdPartyRatingInstance do
  describe 'create some models' do
    it 'all works' do
      nhla = ThirdPartyRatingEntity.create!(name: 'NHLA')

      grade_ap = ThirdPartyRatingGrade.create!(third_party_rating_entity: nhla, grade: 'A+', value: 100)
      ThirdPartyRatingGrade.create!(third_party_rating_entity: nhla, grade: 'A', value: 95)
      grade_c = ThirdPartyRatingGrade.create!(third_party_rating_entity: nhla, grade: 'C', value: 70)

      nhla2023 = described_class.create!(instance: 'NHLA 2023', third_party_rating_entity: nhla)
      nhla2024 = described_class.create!(instance: 'NHLA 2024', third_party_rating_entity: nhla)

      addr = Address.create!(first_line: '1 Main St', second_line: '', city: 'Manchester', state: 'NH', zip: '03101',
                             country: 'US')

      person = Person.create!(name: 'Keith Ammon', address: addr)

      ThirdPartyRating.create!(person: person, third_party_rating_instance: nhla2023,
                               third_party_rating_grade: grade_c)
      ThirdPartyRating.create!(person: person, third_party_rating_instance: nhla2024,
                               third_party_rating_grade: grade_ap)

      expect(person.third_party_ratings.count).to eq(2)
    end
  end
end
