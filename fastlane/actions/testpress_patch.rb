require 'xcodeproj'

module Fastlane
  module Actions
    class TestpressPatchAction < Action
      def self.run(params)
        action = params[:action]
        case action
        when "identity"
          patch_app_identity(params)
        when "constants"
          patch_swift_constants(params)
        when "flags"
          manage_swift_flags(params)
        when "remove_module"
          remove_ios_module(params)
        else
          UI.user_error!("Unknown action: #{action}")
        end
      end

      def self.patch_app_identity(params)
        project = Xcodeproj::Project.open(params[:project])
        target = project.targets.find { |t| t.product_type == "com.apple.product-type.application" }
        UI.user_error!("No app target found") unless target

        target.build_configurations.each do |cfg|
          cfg.build_settings["PRODUCT_BUNDLE_IDENTIFIER"] = params[:bundle_id]
          cfg.build_settings["PRODUCT_NAME"] = params[:display_name]
          cfg.build_settings["INFOPLIST_KEY_CFBundleDisplayName"] = params[:display_name]
          cfg.build_settings["MARKETING_VERSION"] = params[:version] if params[:version]
          cfg.build_settings["CURRENT_PROJECT_VERSION"] = params[:version_code] if params[:version_code]
        end
        project.save

        # Update Info.plist
        plist = params[:info_plist]
        set_plist_buddy_value("CFBundleIdentifier", params[:bundle_id], plist)
        set_plist_buddy_value("CFBundleDisplayName", params[:display_name], plist)
        set_plist_buddy_value("CFBundleShortVersionString", params[:version], plist) if params[:version]
        set_plist_buddy_value("CFBundleVersion", params[:version_code], plist) if params[:version_code]
      end

      def self.set_plist_buddy_value(key, value, plist)
        escaped = value.to_s.gsub("'", "\\\\'")
        sh("/usr/libexec/PlistBuddy -c \"Set :#{key} #{escaped}\" '#{plist}'") rescue sh("/usr/libexec/PlistBuddy -c \"Add :#{key} string #{escaped}\" '#{plist}'")
      end

      def self.patch_swift_constants(params)
        file_path = params[:file]
        UI.user_error!("File not found: #{file_path}") unless File.exist?(file_path)

        content = File.read(file_path)
        params[:constants].each do |const, value|
          regex = /public static let #{const} = ".*?"/
          content.gsub!(regex, "public static let #{const} = \"#{value}\"")
        end

        File.write(file_path, content)
        UI.success("Patched constants in #{File.basename(file_path)}")
      end

      def self.manage_swift_flags(params)
        project_path = params[:project]
        target_name = params[:target]
        raw_flag = params[:flag]
        enabled = params[:enabled]

        flag_clean = raw_flag.to_s.start_with?("-D") ? raw_flag[2..-1] : raw_flag
        flag_with_d = "-D#{flag_clean}"

        project = Xcodeproj::Project.open(project_path)
        target = project.targets.find { |t| t.name == target_name }
        UI.user_error!("Target #{target_name} not found") unless target

        settings_to_update = [
          'OTHER_SWIFT_FLAGS',
          'SWIFT_ACTIVE_COMPILATION_CONDITIONS',
          'SWIFT_ACTIVE_COMPILATION_CONDITIONS[sdk=iphone*]'
        ]

        target.build_configurations.each do |config|
          settings_to_update.each do |key|
            existing = config.build_settings[key] || '$(inherited)'
            flags = existing.is_a?(String) ? existing.split : (existing.is_a?(Array) ? existing : [])
            target_flag = (key == 'OTHER_SWIFT_FLAGS') ? flag_with_d : flag_clean
            enabled ? (flags << target_flag unless flags.include?(target_flag)) : flags.delete(target_flag)
            config.build_settings[key] = flags.empty? ? nil : flags.join(' ')
          end
        end
        project.save
      end

      def self.remove_ios_module(params)
        project = Xcodeproj::Project.open(params[:project])
        target = project.targets.find { |t| t.name == params[:target] }
        UI.user_error!("Target #{params[:target]} not found") unless target

        (params[:frameworks] || []).each do |fw|
          ref = target.frameworks_build_phase.files.find { |f| f.display_name.include?(fw) }
          target.frameworks_build_phase.remove_file_reference(ref.file_ref) if ref
          target.copy_files_build_phases.each do |phase|
            next unless phase.name&.downcase&.include?("embed")
            ref = phase.files.find { |f| f.display_name.include?(fw) }
            phase.remove_file_reference(ref.file_ref) if ref
          end
        end

        (params[:resources] || []).each do |res|
          ref = target.resources_build_phase.files.find { |f| f.display_name.include?(res) }
          target.resources_build_phase.remove_file_reference(ref.file_ref) if ref
          target.copy_files_build_phases.each do |phase|
            ref = phase.files.find { |f| f.display_name.include?(res) }
            phase.remove_file_reference(ref.file_ref) if ref
          end
        end
        project.save
      end

      def self.description
        "Consolidated Testpress Patching actions (identity, constants, flags, modules)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :action, description: "Action to perform (identity, constants, flags, remove_module)"),
          FastlaneCore::ConfigItem.new(key: :project, description: "Path to .xcodeproj", optional: true),
          FastlaneCore::ConfigItem.new(key: :target, description: "Target name", optional: true),
          FastlaneCore::ConfigItem.new(key: :bundle_id, description: "Bundle identifier", optional: true),
          FastlaneCore::ConfigItem.new(key: :display_name, description: "Display name", optional: true),
          FastlaneCore::ConfigItem.new(key: :version, description: "App version", optional: true),
          FastlaneCore::ConfigItem.new(key: :version_code, description: "App version code", optional: true),
          FastlaneCore::ConfigItem.new(key: :info_plist, description: "Path to Info.plist", optional: true),
          FastlaneCore::ConfigItem.new(key: :file, description: "Path to Swift file", optional: true),
          FastlaneCore::ConfigItem.new(key: :constants, description: "Hash of constants", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :flag, description: "Swift flag", optional: true),
          FastlaneCore::ConfigItem.new(key: :enabled, description: "Enable flag", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :frameworks, description: "Frameworks to remove", is_string: false, optional: true),
          FastlaneCore::ConfigItem.new(key: :resources, description: "Resources to remove", is_string: false, optional: true)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
