require "clients/weather_api_client"

RSpec.describe WeatherApiClient do
  it "loads the json fixture file" do
    json = File.read("spec/fixtures/fake_forecast_response.json")
    data = JSON.parse(json)
    expect(data["location"]["name"]).to eq("South Bend")
  end
  it "ensures WeatherApiClient is defined" do
    expect(WeatherApiClient).to be_a(Class)
  end
end
