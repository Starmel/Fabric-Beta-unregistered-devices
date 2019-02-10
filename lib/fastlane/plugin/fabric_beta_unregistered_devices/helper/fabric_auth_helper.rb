class FabricAuthHelper
  require 'httpclient'


  def initialize
    @http_client = HTTPClient.new :base_url => "https://api.crashlytics.com"
  end

  def get_auth_token(login, password)
    require 'json'

    query = {
        :username => login,
        :password => password,
        :client_id => 'a8f97eb503023b933741db3ff2160fa33204014d162a96d17ca67996fad1414c', # Data from Fabric Mac App
        :client_secret => '9386d1a4ed1c00913d1a2b43bba2961c66a499ce8f9aa67ba73dd232b1357d1a',
        :grant_type => 'password',
        :scope => "organizations apps account beta"
    }

    res = @http_client.post "/oauth/token", query
    json_response = JSON.parse(res.body)
    if res.status == 200
      json_response["access_token"]
    elsif json_response["error_description"]
      raise "\nError from Fabric: #{json_response["error_description"]}"
    else
      raise "\nInvalid response: \nResponse status: #{res.status}\nResponse body: '#{res.body}'"
    end
  end

end