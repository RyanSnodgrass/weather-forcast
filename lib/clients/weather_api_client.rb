require "JSON"
require "net/http"

# This class will be used to make API calls to weatherapi.com.
class WeatherApiClient
  class << self
    API_ROOT_URL = "http://api.weatherapi.com/v1/"

    private

    def build_uri(api_subject, extra_params = {})
      uri = URI("#{API_ROOT_URL}/#{api_subject}.json")
      key_param = { key: ENV["WEATHER_API_KEY"] }
      full_params = key_param.merge(extra_params)
      uri.query = URI.encode_www_form(full_params)
      return uri
    end
  end
end
