Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create update destroy]
      resources :articles

      get '/users/data', to: 'users#data'
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'
    end
  end

  # Catch unmatched routes for custom error routing
  match '*unmatched', to: 'errors#routing', via: :all

  # Root route
  root "home#index"

  # Health check routes
  get "up" => "rails/health#show", as: :rails_health_check
end
