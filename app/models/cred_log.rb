# frozen_string_literal: true

# A credit log entry means that one user's credit has increased or decreased.  Must be tied to a cause.
class CredLog < ApplicationRecord
  belongs_to :user
  belongs_to :cause, polymorphic: true
end
