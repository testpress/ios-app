module Fastlane
  module Actions
    class DownloadAssetAction < Action
      def self.run(params)
        url = params[:url]
        dest = params[:path]

        UI.message("Downloading #{url} to #{dest}")
        sh("curl -L -o '#{dest}' '#{url}'")
      end

      def self.description
        "Download a file using curl"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url, description: "URL to download from"),
          FastlaneCore::ConfigItem.new(key: :path, description: "Destination path")
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
