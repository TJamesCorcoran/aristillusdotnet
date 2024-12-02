# frozen_string_literal: true

class CreateElectionChoices < ActiveRecord::Migration[7.2]
  def change
    create_table :election_choices do |t|
      t.string :name
      t.references :election, null: false, foreign_key: true

      t.timestamps
    end
  end
end
