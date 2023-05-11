require "json"
require "net/http"

# This class isolates the actual call out to the external WeatherAPI service.
# ```
# WeatherApiClient.new.forecast("46615")
# ```
class WeatherApiClient
  API_ROOT_URL = "http://api.weatherapi.com/v1".freeze

  # Make the @live_request instance variable publicly accessible for flagging
  # purposes. I think it belongs better as a flag on the instance rather than part
  # of the response data. It's not part of the response data, it's an implementation
  # detail of this client object.
  attr_reader :live_request

  # Usually the only thing going to the forecast request is the zip code. You could
  # send additional params that are supported by the api by passing in a hash
  # to `extra_params`.
  # For example, by default our application (and WeatherAPI's free billing plan)
  # only supports 3 days of forecast data. If you want to get more days of data, you can
  # pass in a hash like this:
  # ```
  # WeatherApiClient.new.forecast("46615", { days: 5 })
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
    response = cach_or_call_api(api_uri)
    JSON.parse(response.body)
  end

  # If the cache expired, then the cache missed, then this block executes.
  # If that all happens then @live_request sets to true.
  def cach_or_call_api(api_uri)
    @live_request = false
    Rails.cache.fetch(api_uri, expires_in: 30.minutes) do
      @live_request = true
      Net::HTTP.get_response(api_uri)
    end
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
