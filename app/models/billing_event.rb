# frozen_string_literal: true

# A BillingEvent is any time a credit card is charged
class BillingEvent < ApplicationRecord
  has_one :cred_log, as: :cause, dependent: :destroy
end
