Rails.application.routes.draw do
  mount RailsEventStore::Browser => '/res' if Rails.env.development?
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  resources :events, only: [:index] do
    resources :votes, only: [:create]
  end
  # Defines the root path route ("/")
  root "events#index"

  get "/sign-out", to: "auth#sign_out", as: :sign_out
  # get "/sign-in", to: "auth#sign_in"
  # get "/sign-up",  to: "auth#sign_up"
end
