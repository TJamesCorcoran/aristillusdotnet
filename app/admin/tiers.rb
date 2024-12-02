# frozen_string_literal: true

ActiveAdmin.register Tier do
  remove_filter :threshhold_low, :threshhold_high

  permit_params :name, :description
end
