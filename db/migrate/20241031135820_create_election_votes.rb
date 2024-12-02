# frozen_string_literal: true

class CreateElectionVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :election_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :election_choice, null: false, foreign_key: true
      t.references :delegated_clone, null: true, foreign_key: { to_table: :election_votes }

      t.boolean :live, null: false, default: true

      t.timestamps
    end
  end
end
