require 'mini_magick'
require 'fileutils'
require 'json'

module Fastlane
  module Actions
    class TestpressAssetsAction < Action
      def self.run(params)
        action = params[:action]
        case action
        when "icons"
          generate_icons(params)
        when "launch_images"
          generate_launch_images(params)
        when "resize"
          resize_image(params)
        else
          UI.user_error!("Unknown action: #{action}")
        end
      end

      def self.generate_icons(params)
        assets_dir = params[:assets_dir]
        icon_source = params[:source]
        
        appiconset = File.join(assets_dir, "AppIcon.appiconset")
        contents_path = File.join(appiconset, "Contents.json")
        
        UI.user_error!("Missing Icon source: #{icon_source}") unless File.exist?(icon_source)
        UI.user_error!("Missing AppIcon Contents.json: #{contents_path}") unless File.exist?(contents_path)

        contents = JSON.parse(File.read(contents_path))
        contents["images"].each do |img|
          next unless (filename = img["filename"])
          size_str = img["size"]
          scale = img["scale"][/(\d)x/, 1].to_i
          scale = 1 if scale.zero?
          pixels = (size_str.split("x").first.to_f * scale).round
          dest = File.join(appiconset, filename)

          resize_image(source: icon_source, dest: dest, width: pixels, height: pixels, background: "transparent")
        end
      end

      def self.generate_launch_images(params)
        assets_dir = params[:assets_dir]
        launch_source = params[:source]
        bg_color = params[:background_color] || "#FFFFFF"

        login_dest = File.join(assets_dir, "login_screen_image.imageset", "login_screen_image.png")
        resize_image(source: launch_source, dest: login_dest, width: 646, height: 218, background: bg_color)
        
        output_dir = File.join(assets_dir, "LaunchImage.launchimage")
        FileUtils.mkdir_p(output_dir)

        [
          ["LaunchImage-1242@3x~iphoneXsMax-portrait_1242x2688.png", 1242, 2688],
          ["LaunchImage-2688@3x~iphoneXsMax-landscape_2688x1242.png", 2688, 1242],
          ["LaunchImage-828@2x~iphoneXr-portrait_828x1792.png", 828, 1792],
          ["LaunchImage-1792@2x~iphoneXr-landscape_1792x828.png", 1792, 828],
          ["LaunchImage-1125@3x~iphoneX-portrait_1125x2436.png", 1125, 2436],
          ["LaunchImage-2436@3x~iphoneX-landscape_2436x1125.png", 2436, 1125],
          ["splash_screen_1242x2208.png", 1242, 2208],
          ["LaunchImage-2208@3x~iphone6s-landscape_2208x1242.png", 2208, 1242],
          ["splash_screen_1.png", 750, 1334],
          ["splash_screen_640x960.png", 640, 960],
          ["splash_screen_640x1136_2.png", 640, 1136],
          ["splash_screen_768x1024.png", 768, 1024],
          ["splash_screen_1024x768.png", 1024, 768],
          ["splash_screen_4.png", 1536, 2048],
          ["splash_screen_2.png", 2048, 1536]
        ].each do |filename, w, h|
          resize_image(source: launch_source, dest: File.join(output_dir, filename), width: w, height: h, background: bg_color)
        end
      end

      def self.resize_image(params)
        source = params[:source]
        dest = params[:dest]
        width = params[:width]
        height = params[:height]
        resize_mode = params[:resize_mode] || ""
        background = params[:background] || "transparent"

        UI.user_error!("Source missing: #{source}") unless File.exist?(source)

        FileUtils.mkdir_p(File.dirname(dest))
        image = MiniMagick::Image.open(source)
        image.combine_options do |c|
          c.resize "#{width}x#{height}#{resize_mode}"
          c.gravity "center"
          c.background background
          c.extent "#{width}x#{height}"
        end
        image.write(dest)
      end

      def self.description
        "Consolidated Testpress Asset actions (icons, launch images, resizing)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :action, description: "Action to perform (icons, launch_images, resize)"),
          FastlaneCore::ConfigItem.new(key: :assets_dir, description: "Path to .xcassets folder", optional: true),
          FastlaneCore::ConfigItem.new(key: :source, description: "Source image path", optional: true),
          FastlaneCore::ConfigItem.new(key: :dest, description: "Destination image path", optional: true),
          FastlaneCore::ConfigItem.new(key: :width, description: "Target width", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :height, description: "Target height", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :resize_mode, description: "Resize mode", optional: true),
          FastlaneCore::ConfigItem.new(key: :background_color, description: "Background color", optional: true)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
