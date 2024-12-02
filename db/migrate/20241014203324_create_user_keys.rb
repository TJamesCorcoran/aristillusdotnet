# frozen_string_literal: true

# create user_keys, which are keys to attributes that users have
class CreateUserKeys < ActiveRecord::Migration[7.2]
  def change
    create_table :user_keys do |t|
      t.references :user, null: false, foreign_key: true
      t.references :key, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end
  end
end
