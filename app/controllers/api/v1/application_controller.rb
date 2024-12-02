# frozen_string_literal: true

module Api
  module V1
    # serves as a base for all of the API (except for login/logout, which is based on Devise)
    class ApplicationController < ActionController::API
      acts_as_token_authentication_handler_for User

      # simply responds w HTTP error 401 (unauthorized) if token is bad
      #
      before_action :authenticate_user_from_token!
      before_action :set_user

      private

      # sets the var `@user`, nothing more
      def set_user
        @user = User.find_by(email: params[:user_email])
      end

      # after_successful_token_authentication
      def reset_token
        @user.update(authentication_token: Devise.friendly_token)
        # Make the authentication token to be disposable - for example
        # renew_authentication_token!
        Rails.logger.debug { "new token = #{@user.authentication_token}" }
      end

      # a post-controller-action 'hook' that can inspect / modify returned JSON
      def render_json(response)
        # response[:auth] = { user_token: @user.authentication_token }
        render json: response
      end

      # override default
      def authenticate_user_from_token!
        token = request.params[:user_token]
        @auth_token = AuthToken.find_by(authentication_token: token, ip: request.ip)
        unless @auth_token
          return render json: {
            success: false,
            message: 'token not found for this IP'
          }
        end
        unless @auth_token.still_valid?
          return render json: {
            success: false,
            message: 'token expired'
          }
        end
        @auth_token.update!(last_used: DateTime.now)
        @current_user = @auth_token.user
      end
    end
  end
end
