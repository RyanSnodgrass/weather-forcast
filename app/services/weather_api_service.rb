require "clients/weather_api_client"

# This class's job is to massage the response from the API client into something
# usable by the frontend. This keeps the controller and view logic very minimal
# and clean. Any other future API requests should go through this class, which
# would call the WeatherApiClient class internally.
class WeatherApiService
  def initialize(location)
    @location = location
    @client = WeatherApiClient.new
  end

  # Tie everything together and return the data hash
  def request_forecast_data
    if raw_response_hash.key?("error")
      {
        error: raw_response_hash["error"]["message"],
        live_request: @client.live_request,
        days: []
      }
    else
      {
        location: raw_response_hash["location"]["name"],
        live_request: @client.live_request,
        days: raw_response_hash["forecast"]["forecastday"].map do |raw_day_response|
          massage_day_block(raw_day_response)
        end
      }
    end
  end

  private

  # Memoize the API call so it doesn't keep calling. Also remember that this
  # makes it much easier to stub out in tests.
  def raw_response_hash
    @raw_response_hash ||= @client.forecast(@location)
  end

  def massage_day_block(raw_day_response)
    dayname_currenttemp_condition(raw_day_response).merge(
      {
        low_temp: raw_day_response["day"]["mintemp_f"].to_s,
        hi_temp: raw_day_response["day"]["maxtemp_f"].to_s,
        hour: massage_hour_block(raw_day_response)
      }
    )
  end

  # These are the attributes that are different depending on which day it is. Gather them
  # all here at once. Then merge them later.
  def dayname_currenttemp_condition(raw_day_response)
    Time.zone = raw_response_hash["location"]["tz_id"]
    iter_date_object = Time.zone.parse(raw_day_response["date"])
    is_daytime = raw_response_hash["current"]["is_day"]
    # The "forecastday" always returns the current day's worth of forecast data. Should
    # be ok to use it to check whether it's today. Always use the timezone of the "location"
    # rather than system time.
    if iter_date_object.today?
      {
        day: (is_daytime == 1) ? "Today" : "Tonight",
        current_temp: raw_response_hash["current"]["temp_f"].to_s,
        condition: {
          text: raw_response_hash["current"]["condition"]["text"],
          icon: raw_response_hash["current"]["condition"]["icon"]
        }
      }
    elsif iter_date_object.tomorrow?
      {
        day: "Tomorrow",
        current_temp: raw_day_response["day"]["avgtemp_f"].to_s,
        condition: {
          text: raw_day_response["day"]["condition"]["text"],
          icon: raw_day_response["day"]["condition"]["icon"]
        }
      }
    else
      {
        day: iter_date_object.strftime("%A"),
        current_temp: raw_day_response["day"]["avgtemp_f"].to_s,
        condition: {
          text: raw_day_response["day"]["condition"]["text"],
          icon: raw_day_response["day"]["condition"]["icon"]
        }
      }
    end
  end

  # Iterate over the time_intervals using map to create an array of hashes.
  # Input accepts a hash of the raw data for a single day under key "forecastday".
  # Use this when iterating over "forecastday".
  def massage_hour_block(raw_day_response)
    time_intervals.map do |time_string, cordinal|
      # select amongst array of hashes the "time_string" value that matches
      raw_matching_hour = match_hour_to_time_string(time_string, raw_day_response["hour"])
      # return the generated(massaged) hash
      {
        temp: raw_matching_hour["temp_f"].to_s,
        time: cordinal,
        condition: {
          text: raw_matching_hour["condition"]["text"],
          icon: raw_matching_hour["condition"]["icon"]
        }
      }
    end
  end

  # Isolate this logic to reduce size of massage_hour_block
  def match_hour_to_time_string(time_string, raw_day_response_hour)
    # select amongst the array of hashes the "time_string" value that matches
    raw_day_response_hour.find do |raw_hour_hash|
      # Check string against string since the API uses a standard format.
      # Note: it may be faster to convert to DateTime first, but I didn't
      # do any benchmarking. Sticking with this for now.
      raw_hour_hash["time"].split(" ")[-1] == time_string
    end
  end

  # Predefine the HH:MM to cordinal values instead of calculating each time.
  # Makes it easy to iterate since we predifine how many hours and which ones.
  def time_intervals
    {"08:00" => "8AM", "12:00" => "12PM", "16:00" => "4PM", "20:00" => "8PM"}
  end
end
