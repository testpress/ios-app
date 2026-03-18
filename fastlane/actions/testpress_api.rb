require 'json'
require 'net/http'
require 'uri'

module Fastlane
  module Actions
    class TestpressApiAction < Action
      def self.run(params)
        action = params[:action]
        subdomain = params[:subdomain]
        api_access_key = ENV["API_ACCESS_KEY"]
        
        UI.user_error!("Missing API_ACCESS_KEY. Export it before running fastlane.") if api_access_key.to_s.strip.empty?

        case action
        when "fetch_subdomains"
          fetch_subdomains
        when "get_config"
          get_config(subdomain, api_access_key)
        when "update_version"
          update_version(subdomain, api_access_key, params[:version], params[:version_code])
        else
          UI.user_error!("Unknown action: #{action}")
        end
      end

      def self.fetch_subdomains
        base = ENV["USE_TEST_BACKEND"] ? "http://admin.testbench.in:8000" : "https://admin.testpress.in"
        uri = URI("#{base}/api/v2.5/admin/ios/subdomains/")
        
        request = Net::HTTP::Get.new(uri)
        request["API-ACCESS-KEY"] = ENV["API_ACCESS_KEY"]

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"

        UI.message("Fetching all subdomains...")
        response = http.request(request)
        UI.user_error!("Failed to fetch subdomains: #{response.body}") if response.code.to_i >= 400
        JSON.parse(response.body)
      rescue => e
        UI.error("Failed to fetch subdomains: #{e.message}")
        []
      end

      def self.get_config(subdomain, api_access_key)
        uri = URI("https://#{subdomain}.testpress.in/api/v2.5/admin/ios/app-config/")
        request = Net::HTTP::Get.new(uri)
        request["API-ACCESS-KEY"] = api_access_key

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"

        UI.message("Fetching config for #{subdomain}...")
        response = http.request(request)
        parsed = JSON.parse(response.body)

        if parsed["detail"]
          UI.error("API Error: #{parsed["detail"]}")
          UI.user_error!("API Failure: #{parsed['detail']}")
        end
        parsed
      rescue => e
        UI.user_error!("Fetch failed for #{subdomain}: #{e.message}")
      end

      def self.update_version(subdomain, api_access_key, version, version_code)
        uri = URI("https://#{subdomain}.testpress.in/api/v2.5/admin/ios/update/")
        request = Net::HTTP::Put.new(uri)
        request["API-ACCESS-KEY"] = api_access_key
        
        payload = {}
        payload[:version] = version if version
        payload[:version_code] = version_code if version_code
        
        request.body = payload.empty? ? " " : payload.to_json
        request["Content-Type"] = "application/json" unless payload.empty?

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        
        UI.message("🚀 Requesting version bump from backend for #{subdomain}...")
        response = http.request(request)
        
        if response.code.to_i >= 400
          UI.error("Backend update failed: #{response.body}")
          UI.user_error!("Could not update app version on backend.")
        end

        parsed = JSON.parse(response.body)
        UI.success("✅ Backend version updated: #{parsed['version']}")
        parsed
      rescue => e
        UI.user_error!("Backend update error: #{e.message}")
      end

      def self.description
        "Consolidated Testpress API actions (subdomains, config, versioning)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :action, description: "Action to perform (fetch_subdomains, get_config, update_version)"),
          FastlaneCore::ConfigItem.new(key: :subdomain, description: "Subdomain for the action", optional: true),
          FastlaneCore::ConfigItem.new(key: :version, description: "Explicit version name", optional: true),
          FastlaneCore::ConfigItem.new(key: :version_code, description: "Explicit version code", optional: true)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
