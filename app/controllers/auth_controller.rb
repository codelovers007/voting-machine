class AuthController < ApplicationController
  skip_before_action :require_clerk_session!, raise: false

  def sign_out
    # view handles the actual sign out via Clerk JS
  end
end