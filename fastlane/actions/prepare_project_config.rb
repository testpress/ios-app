require 'json'

module Fastlane
  module Actions
    class PrepareProjectConfigAction < Action
      def self.run(params)
        config       = normalize_config(params[:config])
        fastlane_dir = params[:fastlane_dir]

        download_assets(config, fastlane_dir)
        handle_api_key(config, fastlane_dir)

        config["google_plist_path"] = "fastlane/GoogleService-Info.plist"
        save_config_json(config, fastlane_dir)

        config
      end

      def self.normalize_config(config)
        config["subdomain"]         ||= config["testpress_site_subdomain"]
        config["bundle_identifier"] ||= config["package_name"] || config["bundle_id"]
        config["display_name"]      ||= config["app_name"]
        config["app_icon_url"]      ||= config["app_icon"] || config["launcher_xxxhdpi"]
        config["launch_image_url"]  ||= config["launch_image"] || config["login_screen_image"]
        config["google_plist_url"]  ||= config["google_plist"]
        config["api_key_id"]        ||= config["apple_key_id"]
        config["api_key_issuer"]    ||= config["apple_issuer_id"]
        config["api_key_url"]       ||= config["apple_api_key"]
        config["apple_id"]          ||= config["app_store_app_id"]
        config["xcode_scheme"]        = "Testpress.in"
        config
      end

      def self.download_assets(config, fastlane_dir)
        other_action.download_asset(url: config["app_icon_url"],     path: File.join(fastlane_dir, "Icon-1024.png"))         if config["app_icon_url"]
        other_action.download_asset(url: config["launch_image_url"], path: File.join(fastlane_dir, "LaunchImage.png"))       if config["launch_image_url"]
        other_action.download_asset(url: config["google_plist_url"], path: File.join(fastlane_dir, "GoogleService-Info.plist")) if config["google_plist_url"]
      end

      def self.handle_api_key(config, fastlane_dir)
        return unless config["api_key_id"]

        key_file = "AuthKey_#{config['api_key_id']}.p8"
        dest     = File.join(fastlane_dir, key_file)

        if config["api_key_content"]
          File.write(dest, config["api_key_content"])
        elsif config["api_key_url"]
          other_action.download_asset(url: config["api_key_url"], path: dest)
        end

        config["api_key_path"] = "fastlane/#{key_file}"
      end

      def self.save_config_json(config, fastlane_dir)
        File.write(File.join(File.dirname(fastlane_dir), "config.json"), JSON.pretty_generate(config))
      end

      def self.description
        "Normalize config keys, download assets, and prepare API key"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :config,       description: "Raw configuration hash", is_string: false),
          FastlaneCore::ConfigItem.new(key: :fastlane_dir, description: "Absolute path to the fastlane directory")
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
