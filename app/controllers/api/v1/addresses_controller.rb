# frozen_string_literal: true

module Api
  module V1
    # API to deal w addresses
    class AddressesController < ApplicationController
      def index
        render json: Address.all
      end
    end
  end
end
