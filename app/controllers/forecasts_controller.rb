class ForecastsController < ApplicationController
  def index
    # If Geocoder can't find your location, then view New York's
    browser_location = request.location.postal_code || "New York"
    location = params[:q].present? ? params[:q] : browser_location
    @forecast_data = WeatherApiService.new(location).request_forecast_data
  end
end
