Rails.application.routes.draw do
  root  'dashboard#index'
  get   'oauth2/callback', to: 'dashboard#callback'
end
