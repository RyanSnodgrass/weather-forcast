require "JSON"
require "net/http"

# This class will be used to make API calls to weatherapi.com.
class WeatherApiClient
  class << self
    API_ROOT_URL = "http://api.weatherapi.com/v1"

    private

    # Isolate calling the api to it's own method. This will make it easier to
    # stub out in the tests.
    def call_api(api_subject, params)
      api_uri = build_uri(api_subject, params)
      response = Net::HTTP.get_response(api_uri)
      JSON.parse(response.body)
    end

    # Rusable private method to build a uri object for the api call.
    # This could be useful if we add more functionality to the application
    # like calling for history or astronomy data.
    # To use this method, pass in the root level subject and any extra params
    def build_uri(api_subject, extra_params = {})
      uri = URI("#{API_ROOT_URL}/#{api_subject}.json")
      params = { key: ENV["WEATHER_API_KEY"] }.merge(extra_params)
      uri.query = URI.encode_www_form(params)
      return uri
    end
  end
end
