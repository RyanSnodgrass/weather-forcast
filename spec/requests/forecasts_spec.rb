require "rails_helper"

RSpec.describe "Forecasts", type: :request do
  let(:fake_response) { File.read("spec/fixtures/fake_forecast_response.json") }

  describe "GET /index" do
    before(:each) do
      stub_const("ENV", {"WEATHER_API_KEY" => "asdf"})
    end

    it "returns http success" do
      stub_request(:get, "http://api.weatherapi.com/v1/forecast.json?days=3&key=asdf&q=46615")
        .to_return(body: fake_response, status: 200)
      get "/forecasts/index"
      expect(response).to have_http_status(:success)
    end
  end
end
