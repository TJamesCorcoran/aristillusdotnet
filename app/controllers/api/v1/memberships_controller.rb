# frozen_string_literal: true

module Api
  module V1
    # respond to requests about what membership tiers exist
    class MembershipsController < ApplicationController
      def index
        data = Membership.all.map { |m| { id: m.id, name: m.name, description: m.description, price: m.price } }
        render json: { success: true, data: data }
      rescue StandardError => e
        render json: { success: false, error: e.message }
      end
    end
  end
end
