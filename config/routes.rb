require "sidekiq/web"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    get    "sign_in",  to: "pages#home", as: :new_session
    delete "sign_out", to: "devise/sessions#destroy", as: :destroy_session
  end

  resources :archives,      only: %w{index update show}
  resources :bank_accounts, only: %w{index create destroy}

  root "pages#home"
end
