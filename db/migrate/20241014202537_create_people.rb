# frozen_string_literal: true

# create people
class CreatePeople < ActiveRecord::Migration[7.2]
  def change
    create_table :people do |t|
      t.string :name
      t.date :dob
      t.boolean :male, null: false, default: true
      t.string :phone

      # this may cause problems in a migration because the other table doesn't exist yet; I should
      # have re-ordered this migration and the one for addresses.
      #
      # works in production, not devel ?!?!
      #
      # rake db:schema:load is an alternative
      t.references :address, null: false, foreign_key: true

      t.timestamps
    end
    add_index :people, :name, unique: true
  end
end
