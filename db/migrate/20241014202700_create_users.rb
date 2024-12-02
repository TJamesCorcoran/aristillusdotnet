# frozen_string_literal: true

# create users
class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.references :person, null: true
      t.integer :cred, default: 0

      t.timestamps
    end
    add_index :users, :name, unique: true
    add_index :users, :cred
  end
end
