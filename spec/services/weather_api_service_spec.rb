require "rails_helper"

RSpec.describe WeatherApiService do
  let(:subject) { WeatherApiService.new("46615") }
  let(:fake_response) { File.read("spec/fixtures/fake_forecast_response.json") }
  let(:fake_response_hash) { JSON.parse(fake_response) }
  let(:forecast_data_expectation) {
    {
      location: "South Bend",
      days: [
        {
          day: "Today",
          current_temp: "70.0",
          hi_temp: "69.6",
          low_temp: "50.0",
          condition: {
            text: "Sunny",
            icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
          },
          hour: [
            {
              time: "8am",
              temp: "52.3",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "12pm",
              temp: "64.6",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "4pm",
              temp: "68.9",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "8pm",
              temp: "60.3",
              condition: {
                text: "Partly cloudy",
                icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
              }
            }
          ]
        },
        {
          day: "Tomorrow",
          current_temp: "60.9",
          hi_temp: "73.8",
          low_temp: "49.6",
          condition: {
            text: "Sunny",
            icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
          },
          hour: [
            {
              time: "8am",
              temp: "52.9",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "12pm",
              temp: "68.2",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "4pm",
              temp: "73.8",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "8pm",
              temp: "65.1",
              condition: {
                text: "Partly cloudy",
                icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
              }
            }
          ]
        },
        {
          day: "Thursday",
          current_temp: "64.2",
          low_temp: "54.0",
          hi_temp: "78.3",
          condition: {
            text: "Patchy rain possible",
            icon: "//cdn.weatherapi.com/weather/64x64/day/176.png"
          },
          hour: [
            {
              time: "8am",
              temp: "56.7",
              condition: {
                text: "Partly cloudy",
                icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
              }
            },
            {
              time: "12pm",
              temp: "70.0",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "4pm",
              temp: "77.2",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "8pm",
              temp: "66.9",
              condition: {
                text: "Partly cloudy",
                icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
              }
            }
          ]
        }
      ]
    }
  }
  let(:today_massaged) { forecast_data_expectation[:days].first }
  let(:tomorrow_massaged) { forecast_data_expectation[:days].second }
  let(:thursday_massaged) { forecast_data_expectation[:days].first }

  let(:today_raw) { fake_response_hash["forecast"]["forecastday"].first }
  let(:tomorrow_raw) { fake_response_hash["forecast"]["forecastday"].second }
  let(:thursday_raw) { fake_response_hash["forecast"]["forecastday"].third }


  before(:each) do
    stub_const("ENV", {"WEATHER_API_KEY" => "asdf"})
    stub_request(:get, "http://api.weatherapi.com/v1/forecast.json?days=3&key=asdf&q=46615")
      .to_return(body: fake_response, status: 200)
  end

  it "takes the response data and returns in a usable structure" do
    expect(subject.request_forecast_data).to eq(forecast_data_expectation)
  end

  describe "#massage_hour_block" do
    it "returns an 4 element array of hour blocks" do
      hour_blocks = subject.massage_hour_block(today_raw)
      expect(hour_blocks).to eq(today_massaged[:hour])
    end
  end

  describe "#match_hour_to_time_string" do
    let(:raw_day_response_hour) { today_raw["hour"] }

    it "returns the matching hour hash to the time string" do
      expect(subject.match_hour_to_time_string("01:00", raw_day_response_hour))
        # instead of writing out the whole thing, just match on the second element
        .to eq(raw_day_response_hour[1])
    end
  end

  # describe "massage_time_objects" do
  #   it "changes the timestamp type from string to date" do
  #     massaged_time_response = subject.massage_time_objects(fake_response_hash)
  #     binding.irb
  #     first_day = massaged_time_response["forecast"]["forecastday"].first
  #     expect(massaged_time_response["forecast"]["forecastday"].first["date"])
  #       .to eq(DateTime.new(2023, 5, 9))

  #   end
  # end
end
