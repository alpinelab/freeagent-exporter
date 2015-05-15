source 'https://rubygems.org'

ruby '2.2.2'

gem 'rails', '4.1.8'
gem 'pg'
gem 'puma'
gem 'sass-rails', '~> 4.0'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'uglifier', '~> 1.3'
gem 'coffee-rails', '~> 4.0'
gem 'jquery-rails'
gem 'sidekiq'
gem 'sinatra', :require => nil
gem 'haml-rails'
gem 'dotenv-rails', :groups => [:development, :test]

gem 'oauth2'
gem 'devise'
gem 'omniauth-freeagent', github: 'jasiek/omniauth-freeagent'
gem 'freeagent-api-ruby', github: 'alpinelab/freeagent-api-ruby', branch: 'master', require: 'freeagent'
gem 'rubyzip'
gem 'aws-sdk', '~> 2'
gem 'gravatar_image_tag'

group :development do
  gem 'spring'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'rspec-rails', '~> 3.0'
  gem 'shoulda-matchers'
  gem 'capybara'
end

group :production do
  gem 'rails_12factor'
end
