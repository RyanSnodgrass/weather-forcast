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
    # response_hash = message_time_objects(response_hash)
    @data[:location] = @response_hash["location"]["name"]
    @data[:days] = @response_hash[]
  end

  def massage_hour_block(raw_day_response)
    # instantiate variable to house hour data
    hours_data = []
    # iterate over the time intervals
    time_intervals.each do |time_string, cordinal|

      # select amongst the array of hashes the "time_string" value that matches
      matching_hour = match_hour_to_time_string(time_string, raw_day_response["hour"])
      # hours_data.append(
      #   {
      #     hour_data[matching_hour]
      #   }
      # )
    end
  end

  # isolate this logic to reduce size of massage_hour_block
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

  private

  def time_intervals
    {"08:00" => "8AM", "12:00" => "12PM", "16:00" => "4PM", "20:00" => "8PM"}
  end

  # We're dealing a lot with time objects so it makes sense to precompile the
  # timestamp strings into a DateTime object. Do this once instead of multiple
  # times during each iteration. Not doing all the timestamps, just the ones we
  # need now.
  # def massage_time_objects(response_hash)
  #   Hash[response_hash.map do |k, v|

  #   end
  #   response_hash["forecast"]["forecastday"].each do |raw_day|
  #     raw_day["date"] = DateTime.parse(raw_day["date"])
  #   end
  # end
end
