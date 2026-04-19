require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class UpdateIosAppVersionAction < Action
      def self.run(params)
        api_access_key = ENV["API_ACCESS_KEY"].to_s.strip
        UI.user_error!("Missing API_ACCESS_KEY. Export it before running fastlane.") if api_access_key.empty?

        uri     = URI("https://#{params[:subdomain]}.testpress.in/api/v2.5/admin/ios/update/")
        request = Net::HTTP::Put.new(uri)
        request["API-access-key"] = api_access_key

        payload = {}
        payload[:version]      = params[:version]      if params[:version]
        payload[:version_code] = params[:version_code] if params[:version_code]

        request.body           = payload.empty? ? " " : payload.to_json
        request["Content-Type"] = "application/json"   unless payload.empty?

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
        UI.user_error!("Could not update app version for #{params[:subdomain]}") if response.code.to_i >= 400

        JSON.parse(response.body)
      rescue => error
        UI.user_error!("Failed to update app version for #{params[:subdomain]}: #{error.message}")
      end

      def self.description
        "Update iOS app version on the Testpress backend"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :subdomain,    description: "Institute subdomain to update"),
          FastlaneCore::ConfigItem.new(key: :version,      description: "App version string (e.g. 1.2.3)", optional: true),
          FastlaneCore::ConfigItem.new(key: :version_code, description: "App build number",                optional: true)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
