# frozen_string_literal: true

# rating entities e.g. NHLA
class CreateThirdPartyRatingEntities < ActiveRecord::Migration[7.2]
  def change
    create_table :third_party_rating_entities do |t|
      t.string :name

      t.timestamps
    end
  end
end
