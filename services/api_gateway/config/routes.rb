Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      match 'auth/*path', to: 'proxy#forward_auth', via: :all
    end
  end
end
