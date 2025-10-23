#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "❌ Config file not found: $CONFIG_FILE"
  exit 1
fi

# Parse JSON values
APP_SUBDOMAIN=$(jq -r '.subdomain' "$CONFIG_FILE")
APP_APPLE_ID=$(jq -r '.apple_id' "$CONFIG_FILE")
APP_PRIMARY_COLOR=$(jq -r '.primary_color' "$CONFIG_FILE")
GOOGLE_PLIST_PATH=$(jq -r '.google_plist_path' "$CONFIG_FILE")
ZOOM_ENABLED=$(jq -r '.features.zoom_enabled' "$CONFIG_FILE")
DISPLAY_NAME=$(jq -r '.display_name' "$CONFIG_FILE")

echo "🚀 Starting Fastlane automation..."
echo "🔹 Subdomain: $APP_SUBDOMAIN"
echo "🔹 Apple ID: $APP_APPLE_ID"
echo "🔹 Primary Color: $APP_PRIMARY_COLOR"
echo "🔹 Google plist: $GOOGLE_PLIST_PATH"
echo "🔹 Zoom enabled: $ZOOM_ENABLED"

# Initialize an array to track executed tasks
EXECUTED_TASKS=()

# 1️⃣ Generate App Icons
fastlane generate_app_icons
EXECUTED_TASKS+=("App Icons generated")

# 2️⃣ Generate Login Screen Images
fastlane generate_login_image
EXECUTED_TASKS+=("Login Screen Images generated")

# 3️⃣ Generate Launch Images
fastlane generate_launch_images
EXECUTED_TASKS+=("Launch Images generated")

# 4️⃣ Update App Constants
fastlane update_app_constants \
  subdomain:"$APP_SUBDOMAIN" \
  app_apple_id:"$APP_APPLE_ID" \
  primary_color:"$APP_PRIMARY_COLOR"
EXECUTED_TASKS+=("App Constants updated")

# 5️⃣ Update GoogleService-Info.plist
if [ ! -f "$GOOGLE_PLIST_PATH" ]; then
  echo "❌ Google plist not found at $GOOGLE_PLIST_PATH"
  exit 1
fi
fastlane update_google_service_plist
EXECUTED_TASKS+=("GoogleService-Info.plist updated")

# 6️⃣ Disable Zoom (conditional)
if [ "$ZOOM_ENABLED" = "true" ]; then
  EXECUTED_TASKS+=("Zoom kept enabled")
else
  fastlane disable_zoom
  fastlane remove_zoom_module
  EXECUTED_TASKS+=("Zoom disabled and removed")
fi

echo "🔹 Updating Bundle Display Name..."
fastlane update_bundle_display_name display_name:"$DISPLAY_NAME"
# 7️⃣ Update App Identity (Bundle Identifier + Display Name)
echo "🔹 Updating app identity (bundle ID and display name)..."

APP_BUNDLE_IDENTIFIER=$(jq -r '.bundle_identifier' "$CONFIG_FILE")
echo "This is updating the bundle id"
fastlane update_app_identity \
  bundle_identifier:"$APP_BUNDLE_IDENTIFIER" \
  display_name:"$DISPLAY_NAME"
EXECUTED_TASKS+=("App Identity (bundle ID + display name) updated")
 

EXECUTED_TASKS+=("Updated Bundle Display name")
# -----------------------------
# 🎉 Final Summary
# -----------------------------
echo ""
echo "✅ Fastlane Automation Summary:"
for task in "${EXECUTED_TASKS[@]}"; do
  echo "   - $task"
done
echo "🎉 All tasks completed successfully!"

