Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/reports/membership_delta', to: 'reports#membership_delta'
  post '/webhooks/stripe', to: 'webhooks#stripe'
end
