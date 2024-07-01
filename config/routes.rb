Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[create update destroy]

      get '/data', to: 'users#data'
      post '/login', to: 'sessions#create'
      delete '/logout', to: 'sessions#destroy'

      resources :articles, only: %i[index create update destroy show]
    end
  end

  # Health check routes
  get "up" => "rails/health#show", as: :rails_health_check
end
