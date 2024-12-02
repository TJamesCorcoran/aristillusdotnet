# frozen_string_literal: true

# create groups that users can belongs to
class CreateGroups < ActiveRecord::Migration[7.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :groups, :name, unique: true
  end
end
