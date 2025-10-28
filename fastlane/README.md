fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### generate_app_icons

```sh
[bundle exec] fastlane generate_app_icons
```

Generate all AppIcon sizes from Icon-1024.png

### generate_login_image

```sh
[bundle exec] fastlane generate_login_image
```

Generate login_screen_image.png (646×218)

### generate_launch_images

```sh
[bundle exec] fastlane generate_launch_images
```

Generate every launch image from LaunchImage.png

<<<<<<< HEAD
### disable_zoom_code

```sh
[bundle exec] fastlane disable_zoom_code
```

Comment out Zoom-related Swift files

### remove_zoom_module

```sh
[bundle exec] fastlane remove_zoom_module
```

Remove Zoom xcframework & bundle from the Xcode project

=======
>>>>>>> 906c5c9f (Fastlane local automation)
### deploy

```sh
[bundle exec] fastlane deploy
```

Full iOS re-brand / asset generation pipeline

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
