# frozen_string_literal: true

class CreateElections < ActiveRecord::Migration[7.2]
  def change
    create_table :elections do |t|
      t.string :name
      t.string :description
      t.references :tier, null: false, foreign_key: true
      t.datetime :open_datetime
      t.datetime :close_datetime
      t.boolean :finalized, null: false, default: false
      t.timestamps
    end
  end
end
