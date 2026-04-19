require 'xcodeproj'
require 'mini_magick'
require 'fileutils'
require 'net/http'
require 'uri'
require 'json'

module Fastlane
  module Actions
    class CustomizeIosAppAction < Action
      LAUNCH_SIZES = [
        ["LaunchImage-1242@3x~iphoneXsMax-portrait_1242x2688.png",   1242, 2688],
        ["LaunchImage-2688@3x~iphoneXsMax-landscape_2688x1242.png",  2688, 1242],
        ["LaunchImage-828@2x~iphoneXr-portrait_828x1792.png",        828,  1792],
        ["LaunchImage-1792@2x~iphoneXr-landscape_1792x828.png",      1792, 828 ],
        ["LaunchImage-1125@3x~iphoneX-portrait_1125x2436.png",       1125, 2436],
        ["LaunchImage-2436@3x~iphoneX-landscape_2436x1125.png",      2436, 1125],
        ["splash_screen_1242x2208.png",                              1242, 2208],
        ["LaunchImage-2208@3x~iphone6s-landscape_2208x1242.png",     2208, 1242],
        ["splash_screen_1.png",                                       750, 1334],
        ["splash_screen_640x960.png",                                 640,  960],
        ["splash_screen_640x1136_2.png",                              640, 1136],
        ["splash_screen_768x1024.png",                                768, 1024],
        ["splash_screen_1024x768.png",                               1024,  768],
        ["splash_screen_4.png",                                      1536, 2048],
        ["splash_screen_2.png",                                      2048, 1536]
      ].freeze

      def self.run(params)
        config       = params[:config]
        fastlane_dir = params[:fastlane_dir]
        root_dir     = File.dirname(fastlane_dir)

        project_path      = File.join(root_dir, "ios-app.xcodeproj")
        info_plist_path   = File.join(root_dir, "ios-app", "Info.plist")
        assets_dir        = File.join(root_dir, "ios-app", "Assets.xcassets")
        constants_path    = File.join(root_dir, "ios-app", "Utils", "AppConstants.swift")
        entitlements_path = File.join(root_dir, "ios-app", "ios-app.entitlements")
        icon_source       = File.join(fastlane_dir, "Icon-1024.png")
        launch_source     = File.join(fastlane_dir, "LaunchImage.png")

        patch_identity(project_path, info_plist_path, config, params[:provisioning_profile])

        patch_constants(constants_path, {
          "SUBDOMAIN"     => config["subdomain"],
          "APP_APPLE_ID"  => config["apple_id"],
          "PRIMARY_COLOR" => config["primary_color"]
        }) if File.exist?(constants_path)

        configure_zoom(project_path, config.dig("features", "zoom_enabled") == true)
        patch_entitlements(project_path, entitlements_path, config["subdomain"])

        generate_icons(assets_dir, icon_source)                                          if File.exist?(icon_source)
        generate_launch_images(assets_dir, launch_source, config["image_background"]) if File.exist?(launch_source)
      end

      def self.patch_identity(project_path, plist_path, config, provisioning_profile = nil)
        project = Xcodeproj::Project.open(project_path)
        team_id = config["team_id"]
        UI.user_error!("Missing team_id or apple_team_id in API config. Fix it in the dashboard.") if team_id.to_s.empty?

        project.targets.each do |target|
          target.build_configurations.each do |cfg|
            cfg.build_settings["CODE_SIGN_STYLE"] = "Manual"
            cfg.build_settings["DEVELOPMENT_TEAM"] = team_id
            cfg.build_settings["CODE_SIGN_IDENTITY"] = "Apple Distribution"

            if target.product_type != "com.apple.product-type.application"
              cfg.build_settings["CODE_SIGNING_REQUIRED"] = "NO"
              cfg.build_settings["CODE_SIGNING_ALLOWED"] = "NO"
              cfg.build_settings["PROVISIONING_PROFILE_SPECIFIER"] = ""
            end

            # Apply bundle ID and names to all targets if they match common prefix or are the main target
            if target.product_type == "com.apple.product-type.application"
              cfg.build_settings["PRODUCT_BUNDLE_IDENTIFIER"]        = config["bundle_identifier"]
              cfg.build_settings["PRODUCT_NAME"]                     = config["display_name"]
              cfg.build_settings["INFOPLIST_KEY_CFBundleDisplayName"] = config["display_name"]
              cfg.build_settings["MARKETING_VERSION"]                = config["version"]           if config["version"]
              cfg.build_settings["CURRENT_PROJECT_VERSION"]          = config["version_code"].to_s if config["version_code"]
              cfg.build_settings["PROVISIONING_PROFILE_SPECIFIER"]  = provisioning_profile if provisioning_profile
            end
          end
        end
        project.save

        set_plist_value("CFBundleIdentifier",         config["bundle_identifier"], plist_path)
        set_plist_value("CFBundleDisplayName",        config["display_name"],      plist_path)
        set_plist_value("CFBundleShortVersionString",  config["version"],           plist_path) if config["version"]
        set_plist_value("CFBundleVersion",            config["version_code"].to_s,  plist_path) if config["version_code"]
      end

      # Replaces `public static let NAME = "old"` with the new value in AppConstants.swift
      def self.patch_constants(file_path, constants)
        content = File.read(file_path)
        constants.each do |name, value|
          content.gsub!(/public static let #{name} = ".*?"/, "public static let #{name} = \"#{value}\"")
        end
        File.write(file_path, content)
      end

      def self.configure_zoom(project_path, enabled)
        project   = Xcodeproj::Project.open(project_path)
        coursekit = project.targets.find { |t| t.name == "CourseKit" } || project.targets.first

        coursekit.build_configurations.each do |cfg|
          ["OTHER_SWIFT_FLAGS", "SWIFT_ACTIVE_COMPILATION_CONDITIONS", "SWIFT_ACTIVE_COMPILATION_CONDITIONS[sdk=iphone*]"].each do |key|
            flags = Array(cfg.build_settings[key] || "$(inherited)").flat_map(&:split)
            flag  = key == "OTHER_SWIFT_FLAGS" ? "-DZOOM_ENABLED" : "ZOOM_ENABLED"
            enabled ? (flags << flag unless flags.include?(flag)) : flags.delete(flag)
            cfg.build_settings[key] = flags.empty? ? nil : flags.join(" ")
          end
        end

        unless enabled
          project.targets.each do |target|
            [target.frameworks_build_phase, *target.copy_files_build_phases.select { |p| p.name&.downcase&.include?("embed") }].each do |phase|
              ref = phase.files.find { |f| f.display_name.include?("MobileRTC.xcframework") }
              phase.remove_file_reference(ref.file_ref) if ref
            end
            ref = target.resources_build_phase.files.find { |f| f.display_name.include?("MobileRTCResources.bundle") }
            target.resources_build_phase.remove_file_reference(ref.file_ref) if ref
          end
        end

        project.save
      end

      def self.patch_entitlements(project_path, entitlements_path, subdomain)
        return if subdomain == "staging"

        uri     = URI("https://#{subdomain}.testpress.in/api/v2.3/settings/")
        request = Net::HTTP::Get.new(uri.request_uri)
        request["API-access-key"] = ENV["API_ACCESS_KEY"]

        response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
        return unless response.is_a?(Net::HTTPSuccess)

        domain_url = JSON.parse(response.body)["domain_url"]
        return unless domain_url

        domain = domain_url.gsub(/^https?:\/\//, "")
        File.write(entitlements_path, {
          "aps-environment"                        => "production",
          "com.apple.developer.associated-domains" => ["applinks:#{domain}"]
        }.to_plist)

        project    = Xcodeproj::Project.open(project_path)
        app_target = project.targets.find { |t| t.product_type == "com.apple.product-type.application" }
        app_target.build_configurations.each { |cfg| cfg.build_settings["CODE_SIGN_ENTITLEMENTS"] = entitlements_path }
        project.save
      end

      def self.generate_icons(assets_dir, source)
        appiconset = File.join(assets_dir, "AppIcon.appiconset")
        JSON.parse(File.read(File.join(appiconset, "Contents.json")))["images"].each do |img|
          next unless (filename = img["filename"])
          scale  = img["scale"][/(\d)x/, 1].to_i
          pixels = (img["size"].split("x").first.to_f * [scale, 1].max).round
          resize_image(source, File.join(appiconset, filename), pixels, pixels)
        end
      end

      def self.generate_launch_images(assets_dir, source, bg_color)
        bg         = bg_color || "#FFFFFF"
        launch_dir = File.join(assets_dir, "LaunchImage.launchimage")
        resize_image(source, File.join(assets_dir, "login_screen_image.imageset", "login_screen_image.png"), 646, 218, bg)
        LAUNCH_SIZES.each do |filename, w, h|
          resize_image(source, File.join(launch_dir, filename), w, h, bg)
        end
      end

      def self.set_plist_value(key, value, plist)
        escaped = value.to_s.gsub("'", "\\\\'")
        sh("/usr/libexec/PlistBuddy -c \"Set :#{key} #{escaped}\" '#{plist}'") rescue \
          sh("/usr/libexec/PlistBuddy -c \"Add :#{key} string #{escaped}\" '#{plist}'")
      end

      def self.resize_image(source, dest, w, h, bg = "transparent")
        FileUtils.mkdir_p(File.dirname(dest))
        image = MiniMagick::Image.open(source)
        image.combine_options do |c|
          c.resize     "#{w}x#{h}"
          c.gravity    "center"
          c.background bg
          c.extent     "#{w}x#{h}"
        end
        image.write(dest)
      end

      def self.description
        "Customize the iOS app: identity, Swift constants, feature flags, entitlements, icons, and launch images"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :config,               description: "Normalized configuration hash", is_string: false),
          FastlaneCore::ConfigItem.new(key: :fastlane_dir,         description: "Absolute path to the fastlane directory"),
          FastlaneCore::ConfigItem.new(key: :provisioning_profile, description: "Provisioning profile UDID to apply", optional: true)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
