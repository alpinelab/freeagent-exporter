require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == Rails.application.secrets.sidekiq_username && password == Rails.application.secrets.sidekiq_password
end if Rails.env.production?
