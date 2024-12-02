# frozen_string_literal: true

class PersonAddrNullable < ActiveRecord::Migration[7.2]
  def change
    change_column_null :people, :address_id, true
  end
end
