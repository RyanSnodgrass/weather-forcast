class ForecastsController < ApplicationController
  def index
    location = params[:q].present? ? params[:q] : "46615"
    @forecast_data = WeatherApiService.new(location).request_forecast_data
  end
end
