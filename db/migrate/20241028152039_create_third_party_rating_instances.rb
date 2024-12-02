# frozen_string_literal: true

# A rating entity (e.g. NHLA) issues rating reports multiple times
# (e.g. NHLA 2023).  This records one rating instance.
#
class CreateThirdPartyRatingInstances < ActiveRecord::Migration[7.2]
  def change
    create_table :third_party_rating_instances do |t|
      t.references :third_party_rating_entity, null: false, foreign_key: true
      t.string :instance

      t.timestamps
    end
  end
end
