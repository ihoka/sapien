class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Authentication
  before_action :require_authentication

  private

  def current_user
    return nil unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end
  helper_method :current_user

  def user_signed_in?
    current_user.present?
  end
  helper_method :user_signed_in?

  def require_authentication
    unless user_signed_in?
      redirect_to auth_login_path, alert: "Please log in to continue"
    end
  end
end
