Rails.application.routes.draw do
  get "forecasts/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "forecasts#index"
end
