class ForecastsController < ApplicationController
  def index
    @forecast_data = {
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
  end
end
