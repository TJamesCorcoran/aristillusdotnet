# frozen_string_literal: true

class AddDateToRatingInstance < ActiveRecord::Migration[7.2]
  def change
    change_table :third_party_rating_instances, bulk: true do |t|
      t.column :interval_begin, :datetime
      t.column :interval_end, :datetime
    end
  end
end
