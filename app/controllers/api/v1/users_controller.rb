# frozen_string_literal: true

module Api
  module V1
    # API to deal w users
    class UsersController < ApplicationController
      skip_before_action :authenticate_user_from_token!, only: %i[create verify ping]
      skip_before_action :set_user, only: %i[create ping ping_auth]

      def ping
        render json: { success: true, message: 'users ping command worked' }
      end

      def ping_auth
        render json: { success: true, message: 'users ping_auth command worked' }
      end

      # XXX
      #    just for demo
      def index
        render_json({ success: true, data: User.all })
      rescue StandardError => e
        render_json({ success: false, error: e.message })
      end

      # XXX
      #    just for demo
      def show
        render_json({ success: false, data: User.find(params[:id]) })
      rescue StandardError => e
        render_json({ success: false, error: e.message })
      end

      def create
        user = User.create!(email: params[:email], password: 'password')
        render_json({ success: true, data: user })
      rescue StandardError => e
        render_json({ success: false, error: e.message })
      end

      def verify
        User.confirm_by_token(params[:token])
        user = User.find_by(confirmation_token: params[:token])
        raise "user not found with token #{params[:token]}" unless user

        #        render_json({ success: true, data: user.merge({ confirmation_token: user.confirmation_token }) })
        render_json({ success: true, data: user })
      rescue StandardError => e
        render_json({ success: false, error: e.message })
      end

      def get_reputation
        user = User.find_by(id: params[:id])
        return render_json({ success: false, error: 'user not found' }) unless user

        tier = user.get_tier
        render_json({ success: true,
                      data: { id: user.id, reputation: user.get_cred, tier: { id: tier&.id, name: tier&.name } } })
      end
    end
  end
end
