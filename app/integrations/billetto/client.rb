module Billetto
  class Client
    BASE_URL = "https://billetto.dk/api/v3/public/events"

    def initialize
      @access_key = Rails.application.credentials.dig(:billetto, :access_key)
      @secret_key = Rails.application.credentials.dig(:billetto, :secret_key)
    end

    def get_events(limit = 10)
      uri = URI("#{BASE_URL}?limit=#{limit}")

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(uri)

      request["Accept"] = "application/json"
      request["Api-Keypair"] = "#{@access_key}:#{@secret_key}"

      response = http.request(request)

      JSON.parse(response.body)
    end
  end
end
