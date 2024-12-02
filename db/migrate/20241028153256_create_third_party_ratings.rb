# frozen_string_literal: true

class CreateThirdPartyRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :third_party_ratings do |t|
      t.references :person, null: false, foreign_key: true
      t.references :third_party_rating_instance, null: false, foreign_key: true
      t.references :third_party_rating_grade, null: false, foreign_key: true

      t.timestamps
    end
  end
end
