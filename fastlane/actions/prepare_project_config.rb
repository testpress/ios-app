require 'json'

module Fastlane
  module Actions
    class PrepareProjectConfigAction < Action
      def self.run(params)
        config = params[:config]
        fastlane_dir = params[:fastlane_dir]
        
        config["subdomain"]         ||= config["testpress_site_subdomain"]
        config["bundle_identifier"] ||= config["package_name"]
        config["bundle_identifier"] ||= config["bundle_id"]
        config["display_name"]      ||= config["app_name"]
        config["app_icon_url"]      ||= config["app_icon"]
        config["launch_image_url"]  ||= config["launch_image"] || config["login_screen_image"]
        config["google_plist_url"]  ||= config["google_plist"]
        config["api_key_id"]        ||= config["apple_key_id"]
        config["api_key_issuer"]    ||= config["apple_issuer_id"]
        config["api_key_url"]       ||= config["apple_api_key"]
        config["apple_id"]          ||= config["app_store_app_id"]
        config["domain_url"]        ||= config["domain"]

        config["api_key_id"]     = ENV["APPLE_API_KEY_ID"]     || config["api_key_id"]
        config["api_key_issuer"] = ENV["APPLE_API_KEY_ISSUER"] || config["api_key_issuer"]
        config["apple_id"]       = ENV["APPLE_APP_ID"]         || config["apple_id"]
        config["scheme"]         = ENV["SCHEME_NAME"]         || config["scheme"]

        icon_path = File.join(fastlane_dir, "Icon-1024.png")
        launch_path = File.join(fastlane_dir, "LaunchImage.png")
        google_plist = File.join(fastlane_dir, "GoogleService-Info.plist")

        other_action.download_asset(url: config["app_icon_url"] || config["launcher_xxxhdpi"], path: icon_path) if config["app_icon_url"] || config["launcher_xxxhdpi"]
        other_action.download_asset(url: config["launch_image_url"], path: launch_path) if config["launch_image_url"]
        other_action.download_asset(url: config["google_plist_url"], path: google_plist) if config["google_plist_url"]

        key_file = "AuthKey_#{config['api_key_id']}.p8"
        dest = File.join(fastlane_dir, key_file)
        if ENV["APPLE_API_KEY_CONTENT"]
          File.write(dest, ENV["APPLE_API_KEY_CONTENT"])
        elsif config["api_key_url"]
          other_action.download_asset(url: config["api_key_url"], path: dest)
        end

        config["google_plist_path"] = "fastlane/GoogleService-Info.plist"
        config["api_key_path"]      = "fastlane/#{key_file}"
        
        config_out = File.join(File.dirname(fastlane_dir), "config.json")
        File.write(config_out, JSON.pretty_generate(config))
        
        config
      end

      def self.description
        "Prepare project configuration, download assets, and handle API keys"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :config, description: "Raw configuration hash", is_string: false),
          FastlaneCore::ConfigItem.new(key: :fastlane_dir, description: "Path to fastlane directory")
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
