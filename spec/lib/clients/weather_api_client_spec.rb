require "rails_helper"
require "clients/weather_api_client"

RSpec.describe WeatherApiClient do
  let(:subject) { WeatherApiClient.new }
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
      allow_any_instance_of(WeatherApiClient).to receive(:call_api)
        .with("forecast", expected_params).and_return(fake_response_hash)
      # Call the forecast method with only the required param: zipcode
      forecast = subject.forecast("46615")
      expect(forecast).to be_a(Hash)
      expect(forecast["location"]["name"]).to eq("South Bend")
    end
  end

  describe "caching the api call" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    # eating own dogfood to generate api_uri
    let(:api_uri) { subject.send(:build_uri, "forecast", q: "46615") }
    let(:past_expiration_date) { Time.zone.now + 35.minutes }

    before(:each) do
      # Resist temptation to turn on caching across the test suite. Try to turn it on
      # only when you need to test it.
      allow(Rails).to receive(:cache).and_return(memory_store)
      stub_request(:get, "http://api.weatherapi.com/v1/forecast.json?key=asdf&q=46615")
        .to_return(body: fake_response, status: 200)
      # clear out the cache before every test
      Rails.cache.clear
    end

    it "sets live_request to true when the query is sent out" do
      expect {
        subject.send(:cach_or_call_api, api_uri)
      }.to change { subject.live_request }.from(nil).to(true)
    end

    it "sets live_request to false if cache is hit" do
      # send the first call to set the flag to true and run the real request
      subject.send(:cach_or_call_api, api_uri)
      expect(subject.live_request).to be true
      # send the second call and hit the cache, setting the flag to false
      subject.send(:cach_or_call_api, api_uri)
      expect(subject.live_request).to be false
    end

    it "sets live_request to true if enough time passed to expire cache" do
      # sanity check that the flag is not set on instantiation
      expect(subject.live_request).to be nil
      # miss the cache and make the first call, setting flag to true
      subject.send(:cach_or_call_api, api_uri)
      # time travel past expiration date
      Timecop.travel(past_expiration_date)
      # cache has expired so a real request needs to be sent out
      # and flag gets set back to true
      subject.send(:cach_or_call_api, api_uri)
      expect(subject.live_request).to be true
    end

    # A lot of copy paste here
    it "is consistent across separate instances" do
      first_client = WeatherApiClient.new
      second_client = WeatherApiClient.new
      # first_client misses the cache and sends out a real request
      expect {
        first_client.send(:cach_or_call_api, api_uri)
      }.to change { first_client.live_request }.from(nil).to(true)
      # second_client hits the cache and keeps flag false
      expect {
        second_client.send(:cach_or_call_api, api_uri)
      }.to change { second_client.live_request }.from(nil).to(false)
      # any subsequent calls keep hitting the cache
      expect {
        first_client.send(:cach_or_call_api, api_uri)
      }.to change { first_client.live_request }.from(true).to(false)
      expect {
        second_client.send(:cach_or_call_api, api_uri)
      }.not_to change { second_client.live_request }
      # time travel past expiration date
      Timecop.travel(past_expiration_date)
      # cache has been invalidated and now second_client calls a real
      # request
      expect {
        second_client.send(:cach_or_call_api, api_uri)
      }.to change { second_client.live_request }.from(false).to(true)
      # finally, first_client hits the cache
      expect {
        first_client.send(:cach_or_call_api, api_uri)
      }.not_to change { first_client.live_request }
    end
  end
end
