require 'fastlane/action'
require_relative '../helper/fabric_api_helper'
require_relative '../helper/fabric_auth_helper'

module Fastlane
  module Actions
    class FabricBetaUnregisteredDevicesAction < Action

      UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

      def self.run(params)
        require 'Spaceship'
        require 'credentials_manager'

        # Log in AppleId
        credentials = CredentialsManager::AccountManager.new(user: params[:apple_username])
        Spaceship.login(credentials.user, credentials.password)
        Spaceship.select_team

        # Log in Fabric
        fabric_auth_helper = FabricAuthHelper.new
        access_token = fabric_auth_helper.get_auth_token(params[:fabric_login], params[:fabric_password])

        fabric_api_helper = FabricApiHelper.new access_token

        # Get Fabric Organizations
        profile_info_json = fabric_api_helper.get_profile_info_json

        organizations = profile_info_json["organizations"]

        # Select organization for choosing it api_key
        selected_organization = organizations.find {|organization| organization["name"] == params[:fabric_organization_name]}
        fabric_api_helper.organization_api_key = selected_organization["api_key"]

        # Get all organization projects
        organization_detail_info_json = fabric_api_helper.get_organization_info_json selected_organization["id"]
        projects_json = organization_detail_info_json["apps"].select {|app| app["platform"] == "ios"}

        if projects_json.size > 0
          selected_project = projects_json.find {|project| project["bundle_identifier"] == params[:bundle_identifier]}

          # Get last project release for getting testers from it
          releases_json = fabric_api_helper.get_project_releases_json(selected_project["bundle_identifier"])
          instances = releases_json["instances"]
          if instances && instances.size > 0
            last_release = instances.first

            project_uid = selected_project["bundle_identifier"]
            release_uid = last_release["instance_identifier"]
            display_version = last_release["build_version"]["display_version"]
            build_version = last_release["build_version"]["build_version"]

            release_detail_json = fabric_api_helper.get_project_release_json(project_uid, release_uid, display_version, build_version)

            # v Users in last release v
            entries = release_detail_json["entries"]
            self.puts_testers_info(entries)
            devices = self.select_devices_for_registration(entries)
            self.puts_devices_for_registration(devices)

            devices.to_h {|item| [item[0], item[1]]}
          else
            UI.error "Not found releases in App: #{params[:bundle_identifier]}"
          end
        else
          UI.error "Not found iOS apps in organization."
        end
      end

      def self.select_devices_for_registration(entries)
        registered_device_udids = Spaceship::Portal.device.all.map(&:udid)

        devices_to_register = []

        entries.each do |entry|
          devices = entry["devices"]
          devices.each do |device|
            unless registered_device_udids.include? device["identifier"]
              devices_to_register << ["#{entry["email"]} #{device["name"]}", device["identifier"]]
            end
          end
        end

        devices_to_register
      end

      def self.puts_devices_for_registration(devices)
        require 'terminal-table'
        if devices.size > 0
          UI.success("Unregistered devices:")
          puts Terminal::Table.new :rows => devices, :headings => ["Registration name", "Device uuid"]
        else
          UI.success("All devices is up-to-date!")
        end
      end

      def self.puts_testers_info(entries)
        require 'terminal-table'
        rows = []
        entries.each do |entry|
          rows << [entry["name"], entry["email"], "", "", ""]

          devices = entry["devices"]
          if devices.size > 0
            devices.each {|device| rows << ["", "", device["name"], device["identifier"], device["distribution_available"]]}
          else
            rows << ["", "", "no devices", "", ""]
          end

        end
        puts Terminal::Table.new :rows => rows, :headings => ["Tester name", "Tester email", "Device name", "Device uuid", "Can distribute?"]
      end

      def self.description
        "Get unregistered devices from Fabric Beta."
      end

      def self.authors
        ["Slava Kornienko"]
      end

      def self.return_value
        '{ "Registration name" => "DeviceUID", ... }'
      end

      def self.details
        # Optional:
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        [
            # Fabric options
            FastlaneCore::ConfigItem.new(key: :fabric_login,
                                         env_name: "SYNC_DEVICES_FABRIC_LOGIN",
                                         description: "Username/email for Fabric",
                                         verify_block: proc do |value|
                                           UI.user_error!("No login for Fabric") if value.to_s.length == 0
                                         end),
            FastlaneCore::ConfigItem.new(key: :fabric_password,
                                         env_name: "SYNC_DEVICES_FABRIC_PASSWORD",
                                         description: "Password for Fabric",
                                         sensitive: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("No password for Fabric") if value.to_s.length == 0
                                         end),
            FastlaneCore::ConfigItem.new(key: :fabric_organization_name,
                                         env_name: "SYNC_DEVICES_FABRIC_ORGANIZATION",
                                         description: "Fabric organization name",
                                         sensitive: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("No Fabric organization name") if value.to_s.length == 0
                                         end),
            FastlaneCore::ConfigItem.new(key: :bundle_identifier,
                                         env_name: "SYNC_DEVICES_FABRIC_APP",
                                         description: "Fabric Bundle Identifier (XCode App Bundle)",
                                         sensitive: true,
                                         verify_block: proc do |value|
                                           UI.user_error!("No Fabric project uid") if value.to_s.length == 0
                                         end),

            # SpaceShip options
            FastlaneCore::ConfigItem.new(key: :team_id,
                                         env_name: "REGISTER_DEVICES_TEAM_ID",
                                         code_gen_sensitive: true,
                                         default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                         default_value_dynamic: true,
                                         description: "The ID of your Developer Portal team if you're in multiple teams",
                                         optional: true,
                                         verify_block: proc do |value|
                                           ENV["FASTLANE_TEAM_ID"] = value.to_s
                                         end),
            FastlaneCore::ConfigItem.new(key: :team_name,
                                         env_name: "REGISTER_DEVICES_TEAM_NAME",
                                         description: "The name of your Developer Portal team if you're in multiple teams",
                                         optional: true,
                                         code_gen_sensitive: true,
                                         default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                         default_value_dynamic: true,
                                         verify_block: proc do |value|
                                           ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                         end),
            FastlaneCore::ConfigItem.new(key: :apple_username,
                                         env_name: "DELIVER_USER",
                                         description: "Your Apple ID",
                                         default_value: user,
                                         default_value_dynamic: true)
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

    end
  end
end
