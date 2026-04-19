require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class GetIosAppConfigAction < Action
      def self.run(params)
        api_access_key = ENV["API_ACCESS_KEY"].to_s.strip
        UI.user_error!("Missing API_ACCESS_KEY. Export it before running fastlane.") if api_access_key.empty?

        uri     = URI("https://#{params[:subdomain]}.testpress.in/api/v2.5/admin/ios/app-config/")
        request = Net::HTTP::Get.new(uri)
        request["API-access-key"] = api_access_key

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
        UI.user_error!("Get config failed for #{params[:subdomain]}: HTTP #{response.code}") unless response.is_a?(Net::HTTPSuccess)

        parsed = JSON.parse(response.body)
        UI.user_error!("API error for #{params[:subdomain]}: #{parsed['detail']}") if parsed["detail"]

        parsed
      rescue => error
        UI.user_error!("Fetch config failed for #{params[:subdomain]}: #{error.message}")
      end

      def self.description
        "Fetch the iOS app configuration for a given subdomain"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :subdomain, description: "Institute subdomain to fetch config for")
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
