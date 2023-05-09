require "JSON"
require "net/http"

# This class will be used to make API calls to weatherapi.com.
# These will primarily be Class level methods as it should only be used to call
# one request at a time to the api.
# ```
# WeatherApiClient.forecast("46615")
# ```
class WeatherApiClient
  class << self
    API_ROOT_URL = "http://api.weatherapi.com/v1"

    # Usually the only thing going to the forecast request is the zip code. You could
    # send additional params that are supported by the api by passing in a hash
    # to `extra_params`.
    # For example, by default our application (and WeatherAPI's free billing plan)
    # only supports 3 days of forecast data. If you want to get more days of data, you can
    # pass in a hash like this:
    # ```
    # WeatherApiClient.forecast("46615", { days: 5 })
    # ```
    def forecast(zipcode, params = {})
      params[:q] = zipcode
      params[:days] ||= 3
      call_api("forecast", params)
    end

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
      params = {key: ENV["WEATHER_API_KEY"]}.merge(extra_params)
      uri.query = URI.encode_www_form(params)
      uri
    end
  end
end
