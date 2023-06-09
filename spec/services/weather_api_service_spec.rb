require "rails_helper"

RSpec.describe WeatherApiService do
  let(:subject) { WeatherApiService.new("46615") }
  let(:error_response) { File.read("spec/fixtures/fake_no_location_found_response.json") }
  let(:fake_response) { File.read("spec/fixtures/fake_forecast_response.json") }
  let(:fake_response_hash) { JSON.parse(fake_response) }
  let(:forecast_data_expectation) {
    {
      location: "South Bend",
      live_request: true,
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
              time: "8AM",
              temp: "52.3",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "12PM",
              temp: "64.6",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "4PM",
              temp: "68.9",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "8PM",
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
              time: "8AM",
              temp: "52.9",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "12PM",
              temp: "68.2",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "4PM",
              temp: "73.8",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "8PM",
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
              time: "8AM",
              temp: "56.7",
              condition: {
                text: "Partly cloudy",
                icon: "//cdn.weatherapi.com/weather/64x64/day/116.png"
              }
            },
            {
              time: "12PM",
              temp: "70.0",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "4PM",
              temp: "77.2",
              condition: {
                text: "Sunny",
                icon: "//cdn.weatherapi.com/weather/64x64/day/113.png"
              }
            },
            {
              time: "8PM",
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
  let(:error_data_expectation) {
    {
      error: "No matching location found.",
      live_request: true,
      days: []
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

  before do
    Time.zone = fake_response_hash["location"]["tz_id"]
    Timecop.freeze(Time.zone.local(2023, 5, 9))
  end

  after do
    Timecop.return
  end

  describe "#request_forecast_data" do
    it "takes the response data and returns in a usable structure" do
      data = subject.request_forecast_data
      expect(data).to eq(forecast_data_expectation)
      # Check everything is in order
      expect(data[:days].first[:day]).to eq("Today")
      expect(data[:days].second[:day]).to eq("Tomorrow")
    end

    it "gracefully handles error messages" do
      stub_request(:get, "http://api.weatherapi.com/v1/forecast.json?days=3&key=asdf&q=BadRequest")
        .to_return(body: error_response, status: 400)
      graceful_service = WeatherApiService.new("BadRequest")
      data = graceful_service.request_forecast_data
      expect(data).to eq(error_data_expectation)
    end
  end

  describe "#massage_day_block" do
    it "combines everything and merges the hash for today" do
      day_block = subject.send(:massage_day_block, today_raw)
      expect(day_block).to eq(today_massaged)
    end
  end

  describe "#dayname_currenttemp_condition checks what day it is for current_temp and dayname" do
    it "for a record that matches today" do
      day_name = subject.send(:dayname_currenttemp_condition, today_raw)
      expectation = {
        day: "Today",
        current_temp: "70.0",
        condition: {
          icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
          text: "Sunny"
        }
      }
      expect(day_name).to eq(expectation)
    end

    it "for a record that will be tomorrow and names it such" do
      day_name = subject.send(:dayname_currenttemp_condition, tomorrow_raw)
      expectation = {
        day: "Tomorrow",
        current_temp: "60.9",
        condition: {
          icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
          text: "Sunny"
        }
      }
      expect(day_name).to eq(expectation)
    end

    it "for a record past that it just uses the day of the week" do
      day_name = subject.send(:dayname_currenttemp_condition, thursday_raw)
      expectation = {
        day: "Thursday",
        current_temp: "64.2",
        condition: {
          icon: "//cdn.weatherapi.com/weather/64x64/day/176.png",
          text: "Patchy rain possible"
        }
      }
      expect(day_name).to eq(expectation)
    end
  end

  describe "#massage_hour_block" do
    it "returns an 4 element array of hour blocks" do
      hour_blocks = subject.send(:massage_hour_block, today_raw)
      expect(hour_blocks).to eq(today_massaged[:hour])
    end
  end

  describe "#match_hour_to_time_string" do
    let(:raw_day_response_hour) { today_raw["hour"] }

    it "returns the matching hour hash to the time string" do
      expect(subject.send(:match_hour_to_time_string, "01:00", raw_day_response_hour))
        # instead of writing out the whole thing, just match on the second element
        .to eq(raw_day_response_hour[1])
    end
  end
end
