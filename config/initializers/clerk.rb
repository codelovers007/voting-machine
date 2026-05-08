Clerk.configure do |config|
  config.secret_key = Rails.application.credentials.dig(:clerk, :secret_key)
  config.publishable_key = Rails.application.credentials.dig(:clerk, :publishable_key)
end
