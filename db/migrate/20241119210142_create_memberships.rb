# frozen_string_literal: true

class CreateMemberships < ActiveRecord::Migration[7.2]
  def change
    create_table :memberships do |t|
      t.string :name
      t.string :description
      t.decimal :price

      t.timestamps
    end
  end
end
