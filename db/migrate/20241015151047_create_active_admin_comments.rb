# frozen_string_literal: true

# active_admin gem supports comments in the admin UI
class CreateActiveAdminComments < ActiveRecord::Migration[7.2]
  def self.up
    create_table :active_admin_comments do |t|
      t.string :namespace
      t.text   :body
      t.references :resource, polymorphic: true
      t.references :author, polymorphic: true
      t.timestamps
    end
    add_index :active_admin_comments, [:namespace]
  end

  def self.down
    drop_table :active_admin_comments
  end
end