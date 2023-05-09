require "clients/weather_api_client"

RSpec.describe WeatherApiClient do
  let(:subject) { WeatherApiClient }

  before(:each) do
    stub_const('ENV', {'WEATHER_API_KEY' => 'asdf'})
  end
  it "loads the json fixture file" do
    json = File.read("spec/fixtures/fake_forecast_response.json")
    data = JSON.parse(json)
    expect(data["location"]["name"]).to eq("South Bend")
  end
  it "ensures WeatherApiClient is defined" do
    expect(WeatherApiClient).to be_a(Class)
  end

  describe "#build_uri" do
    it "builds a uri object for the api call with zip params" do
      params = { q: "46615" }
      uri = subject.send("build_uri", "forecast", params)
      expect(uri.request_uri).to eq("/v1/forecast.json?key=asdf&q=46615")
      expect(uri.origin).to eq("http://api.weatherapi.com")
    end
  end
end
