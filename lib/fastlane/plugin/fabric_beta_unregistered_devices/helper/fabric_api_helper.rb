class FabricApiHelper
  attr_writer :organization_api_key
  require 'httpclient'
  require 'json'


  def initialize(auth_token)
    @organization_api_key = ""
    @http_client = HTTPClient.new :base_url => "https://fabric.io", :default_header => {
        :Authorization => "Bearer #{auth_token}"
    }
  end

  def get_profile_info_json
    res = @http_client.get "/api/v3/account"
    parse_or_print_body(res)
  end

  def get_organization_info_json(organization_id)
    res = @http_client.get "/api/v2/organizations/#{organization_id}", :header => {
        :"X-CRASHLYTICS-API-KEY" => @organization_api_key
    }
    parse_or_print_body(res)
  end

  def get_project_releases_json(project_uid)
    res = @http_client.get "http://api.crashlytics.com/spi/v1/platforms/ios/apps/#{project_uid}/releases?", :header => {
        :"X-CRASHLYTICS-API-KEY" => @organization_api_key
    }
    parse_or_print_body(res)
  end

  def get_project_release_json(project_uid, release_uid, build_version, display_version)
    res = @http_client.get "http://api.crashlytics.com/spi/v1/platforms/ios/apps/#{project_uid}/releases/#{release_uid}/access?app%5Bbuild_version%5D=#{build_version}&app%5Bdisplay_version%5D=#{display_version}", :header => {
        :"X-CRASHLYTICS-API-KEY" => @organization_api_key
    }
    parse_or_print_body(res)
  end

  private

  def parse_or_print_body(res)
    begin
      JSON.parse(res.body)
    rescue
      raise "\nResponse status: #{res.status}\nResponse body: '#{res.body}'"
    end
  end

end