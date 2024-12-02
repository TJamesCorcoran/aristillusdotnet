# frozen_string_literal: true

# grades from an entity e.g. NHLA A+
class CreateThirdPartyRatingGrades < ActiveRecord::Migration[7.2]
  def change
    create_table :third_party_rating_grades do |t|
      t.references :third_party_rating_entity, null: false, foreign_key: true
      t.string :grade
      t.integer :value

      t.timestamps
    end
  end
end
