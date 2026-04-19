require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class FetchSubdomainsAction < Action
      def self.run(params)
        uri     = URI("https://sandbox.testpress.in/api/v2.5/admin/ios/subdomains/")
        request = Net::HTTP::Get.new(uri)
        request["API-access-key"] = ENV["API_ACCESS_KEY"]

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
        UI.user_error!("Fetch subdomains failed: HTTP #{response.code}") unless response.is_a?(Net::HTTPSuccess)

        JSON.parse(response.body)
      rescue => error
        UI.user_error!("Fetch subdomains failed: #{error.message}")
      end

      def self.description
        "Fetch all active institute subdomains from Testpress"
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
