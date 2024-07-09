Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create update destroy]

      get '/users/data', to: 'users#data'
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'

      resources :articles
    end
  end

  match '*unmatched', to: 'errors#routing', via: :all

  root "home#index"

  # Health check routes
  get "up" => "rails/health#show", as: :rails_health_check
end
