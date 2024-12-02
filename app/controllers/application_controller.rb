# frozen_string_literal: true

# based controller
class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  def access_denied(exception)
    redirect_to root_path, alert: exception.message
  end
end
