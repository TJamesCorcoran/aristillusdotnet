# frozen_string_literal: true

class CreateCredLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :cred_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :cred
      t.references :cause, polymorphic: true, null: false

      t.timestamps
    end

    create_table :billing_events do |t|
      t.decimal :amount, precision: 6, scale: 2
      t.text    :stripe_charge
      t.timestamps
    end
  end
end
