module ClerkHelpers
  def mock_clerk_session(user_id: "user_123", username: "testuser", first_name: "Test")
    clerk_user = double("ClerkUser",
      id:              user_id,
      username:        username,
      first_name:      first_name,
      email_addresses: []
    )
    clerk_session = double("ClerkSession", user_id: user_id)
    clerk_double  = double("Clerk",
      session: clerk_session,
      user:    clerk_user,
      user_id: user_id
    )
    allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(clerk_double)
    allow_any_instance_of(ApplicationController).to receive(:set_clerk_user) do |controller|
      controller.instance_variable_set(:@clerk_user, clerk_user)
    end
    clerk_double
  end

  def mock_guest_session
    clerk_double = double("Clerk", session: nil, user: nil, user_id: nil)
    allow_any_instance_of(ApplicationController).to receive(:clerk).and_return(clerk_double)
    allow_any_instance_of(ApplicationController).to receive(:set_clerk_user) do |controller|
      controller.instance_variable_set(:@clerk_user, nil)
    end
    clerk_double
  end
end

RSpec.configure do |config|
  config.include ClerkHelpers, type: :controller
  config.include ClerkHelpers, type: :request
end
