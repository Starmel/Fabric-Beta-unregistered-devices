# fabric_beta_unregistered_devices plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-fabric_beta_unregistered_devices)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-fabric_beta_unregistered_devices`, add it to your project by running:

```bash
fastlane add_plugin fabric_beta_unregistered_devices
```

## About fabric_beta_unregistered_devices

Get unregistered devices of your Fabric Beta project release.

Plugin is checking testers in your last app release and verify that all test device included in your Apple Developer Account. 

Warning: This plugin is not automatically add devices to your profile, just checking included.

## For setup required

* fabric_login - Fabric username or email
* fabric_password - Fabric password for authorization (Fabric do not provide CI keys, api keys used for uploading builds to Crashlytics are not allow to see organization Beta releases)
* fabric_organization_name - organization or profile name which own project
* bundle_identifier - App Bundle Id
* apple_username - username of Apple Developer Account
* team_id - if few team in one account. Optional.

Example how to use with automatic registration:
```bash
devices_to_register = fabric_beta_unregistered_devices(
      fabric_login: "login",
      fabric_password: "password",
      fabric_organization_name: "organization",
      bundle_identifier: "identifier",
      apple_username: "username",
      team_id: "team"
  )
register_devices(devices: devices_to_register, username: "username") if devices_to_register.size > 0
```


## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
