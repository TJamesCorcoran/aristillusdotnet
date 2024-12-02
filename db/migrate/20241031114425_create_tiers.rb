# frozen_string_literal: true

class CreateTiers < ActiveRecord::Migration[7.2]
  def change
    create_table :tiers do |t|
      t.string :name
      t.string :description
      t.integer :threshhold_low
      t.integer :threshhold_high

      t.timestamps
    end
  end
end
