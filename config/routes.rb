Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  scope :auth, as: :auth do
    # Signup
    get "signup", to: "auth#new_signup", as: :signup
    post "signup", to: "auth#create_signup"

    # Login
    get "login", to: "auth#new_login", as: :login
    post "login", to: "auth#create_login"

    # Verification
    get "verify/:token", to: "auth#verify", as: :verify
    get "verify_otp", to: "auth#new_otp_verification", as: :new_otp_verification
    post "verify_otp", to: "auth#verify_otp", as: :verify_otp

    # Resend
    post "resend", to: "auth#resend", as: :resend

    # Logout
    delete "logout", to: "auth#destroy", as: :logout
  end

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Root route
  root "dashboard#index"
end
