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

  describe "#call_api" do
    it "calls the api with the correct params and returns a json object" do
      # load json response into memory
      fake_response = File.read("spec/fixtures/fake_forecast_response.json")
      # stub the api call and return json response
      stub_request(:get, "http://api.weatherapi.com/v1/forecast.json?key=asdf&q=46615").
        to_return(body: fake_response, status: 200)
      # call the api
      response = subject.send("call_api", "forecast", { q: "46615" })
      # test a simple value to ensure the response is a json object
      expect(response["location"]["name"]).to eq("South Bend")
    end
  end
end
