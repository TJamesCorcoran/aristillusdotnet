# frozen_string_literal: true

# keys
class CreateKeys < ActiveRecord::Migration[7.2]
  def change
    create_table :keys do |t|
      t.string :name

      t.timestamps
    end
  end
end
