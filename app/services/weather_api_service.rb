require "clients/weather_api_client"
# This class's job is to massage the response from the API client into something usable by the frontend.
# This keeps the controller and view logic very minimal and clean.
# Any other future API requests should go through this class, which calls the Client class internally.
class WeatherApiService
  def initialize(location)
    @location = location
    @client = WeatherApiClient.new
    @data = {}
  end

  def request_forecast_data
    @response_hash = @client.forecast(@location)
    {
      location: @response_hash["location"]["name"],
      days: [

      ]
    }
    # @data[:location] = @response_hash["location"]["name"]
    # @data[:days] = @response_hash[]
  end

  private

  # Iterate over the time_intervals using map to create an array of hashes
  def massage_hour_block(raw_day_response)
    time_intervals.map do |time_string, cordinal|
      # select amongst the array of hashes the "time_string" value that matches
      raw_matching_hour = match_hour_to_time_string(time_string, raw_day_response["hour"])
      {
        temp: raw_matching_hour["temp_f"].to_s,
        time: cordinal,
        condition: {
          text: raw_matching_hour["condition"]["text"],
          icon: raw_matching_hour["condition"]["icon"],
        }
      }
    end
  end

  # Isolate this logic to reduce size of massage_hour_block
  def match_hour_to_time_string(time_string, raw_day_response_hour)
    # select amongst the array of hashes the "time_string" value that matches
    raw_day_response_hour.select do |raw_hour_hash|
      # Check string against string since the API uses a standard format.
      # Note: it may be faster to convert to DateTime first, but I didn't
      # do any benchmarking. Sticking with this for now.
      raw_hour_hash["time"].split(" ")[-1] == time_string
    # select returns an array. We should be pretty confident there will always
    # be only one returned.
    end.first
  end

  # Predefine the HH:MM to cordinal values instead of calculating each time.
  # Also makes it easy to iterate.
  def time_intervals
    {"08:00" => "8AM", "12:00" => "12PM", "16:00" => "4PM", "20:00" => "8PM"}
  end
end
