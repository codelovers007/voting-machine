class ApplicationController < ActionController::Base
  include Clerk::Authenticatable
  before_action :set_clerk_user

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def set_clerk_user
    @clerk_user = clerk.user if clerk.session
  end

  def require_clerk_session!
    unless clerk.session
      sign_in_url =  Rails.application.credentials.dig(:clerk, :sign_in_url)
      redirect_url = Rails.application.credentials.dig(:clerk, :after_sign_in_url)
      redirect_to "#{sign_in_url}?redirect_url=#{CGI.escape(redirect_url)}",
                  allow_other_host: true
    end
  end
end
