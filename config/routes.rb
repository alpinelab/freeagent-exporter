Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  root  'dashboard#index'

  get 'export', to: 'dashboard#export'
end
