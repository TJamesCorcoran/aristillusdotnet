# frozen_string_literal: true

class CreateAuthTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :auth_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :authentication_token, limit: 30, null: false
      t.timestamp :last_used
      t.string :ip
      t.string :useragent

      t.timestamps
    end
    add_index :auth_tokens, %i[user_id ip], unique: true

    remove_column :users, :authentication_token, :string, limit: 30
  end
end
