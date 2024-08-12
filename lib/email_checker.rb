# plugins/email_validator/lib/email_validator/email_checker.rb

require 'net/http'
require 'json'
require 'uri'

module EmailValidator
  class EmailChecker
    API_URL = "https://swot.p.rapidapi.com/check"

    def self.is_academic?(email)
      uri = URI("#{API_URL}?q=#{email}")
      request = Net::HTTP::Get.new(uri)
      request["X-RapidAPI-Key"] = SiteSetting.email_validator_rapidapi_key

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      JSON.parse(response.body)
    end
  end
end
