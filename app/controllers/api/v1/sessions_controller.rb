# frozen_string_literal: true

module Api
  module V1
    # controller to let us log in / log out
    class SessionsController < Devise::SessionsController
      protect_from_forgery with: :null_session

      before_action :sign_in_params, only: :create
      before_action :load_user, only: %i[create delete]

      def ping
        render json: { success: true, message: 'session ping command worked' }
      end

      # sign in
      def create
        if @user.valid_password?(sign_in_params[:user_password])
          token = AuthToken.find_by(user: @user, ip: request.ip)
          if token
            token.update!(useragent: request.user_agent,
                          last_used: DateTime.now)
          else
            token = AuthToken.create!(user: @user,
                                      ip: request.ip,
                                      authentication_token: Devise.friendly_token,
                                      useragent: request.user_agent,
                                      last_used: DateTime.now)
          end

          sign_in 'user', @user
          render json: {
            success: true,
            message: 'Signed In Successfully',
            data: { token: token.authentication_token }
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'Signed In Failed - Unauthorized',
            data: {}
          }, status: :unauthorized
        end
      end

      def delete
        #        @user.ensure_authentication_token
        @user.update(authentication_token: Devise.friendly_token)

        render json: {
          message: 'Signed Out Successfully',
          success: true
        }
      rescue StandardError => e
        render json: {
          success: false,
          error: e.message
        }
      end

      private

      def sign_in_params
        params.permit(:user_email, :user_password)
      end

      def load_user
        @user = User.find_for_database_authentication(email: sign_in_params[:user_email])
        return @user if @user

        render json: {
          message: 'Cannot get User',
          success: false,
          data: {}
        }, status: :failure
      end
    end
  end
end
