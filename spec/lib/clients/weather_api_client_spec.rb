require "clients/weather_api_client"

RSpec.describe WeatherApiClient do
  let(:subject) { WeatherApiClient }
  let(:fake_response) { File.read("spec/fixtures/fake_forecast_response.json") }
  let(:fake_response_hash) { JSON.parse(fake_response) }

  before(:each) do
    stub_const("ENV", {"WEATHER_API_KEY" => "asdf"})
  end

  # This is primarily a sanity check that the file is in fact loading
  # correctly into the specs. This could save a lot of time debugging
  # why a response isn't working correctly.
  it "loads the json fixture file" do
    json = File.read("spec/fixtures/fake_forecast_response.json")
    data = JSON.parse(json)
    expect(data["location"]["name"]).to eq("South Bend")
  end

  describe "#build_uri" do
    it "builds a uri object for the api call with zip params" do
      params = {q: "46615"}
      uri = subject.send(:build_uri, "forecast", params)
      expect(uri.request_uri).to eq("/v1/forecast.json?key=asdf&q=46615")
      expect(uri.origin).to eq("http://api.weatherapi.com")
    end
  end

  describe "#call_api" do
    it "calls the api with the correct params and returns a json object" do
      # load json response into memory
      # stub the api call and return json response
      stub_request(:get, "http://api.weatherapi.com/v1/forecast.json?key=asdf&q=46615")
        .to_return(body: fake_response, status: 200)
      # call the api
      response = subject.send(:call_api, "forecast", {q: "46615"})
      # test a simple value to ensure the response is a json object
      expect(response["location"]["name"]).to eq("South Bend")
    end
  end

  describe "#forecast" do
    it "returns a forecast for a given location by zipcode" do
      # define the expected params that should be passed to the api
      expected_params = {q: "46615", days: 3}
      # stub the api call now that it's isolated and return a pre json parsed response
      allow(WeatherApiClient).to receive(:call_api)
        .with("forecast", expected_params).and_return(fake_response_hash)
      # Call the forecast method with only the required param: zipcode
      forecast = WeatherApiClient.forecast("46615")
      expect(forecast).to be_a(Hash)
      expect(forecast["location"]["name"]).to eq("South Bend")
    end
  end
end