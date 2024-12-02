# frozen_string_literal: true

# confirm new accounts via token in email
class UserAddConfirmable < ActiveRecord::Migration[7.2]
  def change
    ## Devise Confirmable
    change_table(:users, bulk: true) do |t|
      #      t.column :confirmation_token, :string
      #      t.column :confirmed_at, :datetime
      #      t.column :confirmation_sent_at, :datetime
    end
  end
end
