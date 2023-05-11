class ForecastsController < ApplicationController
  def index
    location = "46615"
    @forecast_data = WeatherApiService.new(location).request_forecast_data
  end
end
