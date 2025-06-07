Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'register', to: 'auth#register'
      post 'login', to: 'auth#login'
      get 'profile', to: 'auth#profile'
      post 'refresh_token', to: 'auth#refresh'
      get 'verify_token', to: 'auth#verify'
      get 'logout', to: 'auth#logout'
    end
  end
end
