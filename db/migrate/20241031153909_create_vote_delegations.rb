# frozen_string_literal: true

class CreateVoteDelegations < ActiveRecord::Migration[7.2]
  def change
    create_table :vote_delegations do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :rank
      t.boolean :live, null: false, default: true
      t.references :delegate, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :vote_delegations, %i[user_id rank], unique: true
  end
end
