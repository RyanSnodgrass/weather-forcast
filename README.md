# README

[See this live!](https://weather-forecasterio.herokuapp.com/)

I started this with my own [rails template](https://github.com/RyanSnodgrass/personal-rails-template). It installs a couple gems that I always use like linters and github workflows.

## Setup

```
bundle install
bundle exec rails assets:precompile
bundle exec rails s
```

### Requirements
- Ruby 3.1.3

### Weather API
Sign up for free at [WeatherAPI.com](https://www.weatherapi.com/) and grab your API key. Rename `.env.example` to `.env` and paste your key in there.
