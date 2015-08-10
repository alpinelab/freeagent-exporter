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
gem 'statesman'
gem 'oauth2'
gem 'devise'
gem 'omniauth-freeagent', github: 'jasiek/omniauth-freeagent'
gem 'freeagent-api-ruby', github: 'alpinelab/freeagent-api-ruby', branch: 'master', require: 'freeagent'
gem 'rubyzip'
gem 'aws-sdk', '~> 2'
gem 'gravatar_image_tag'
gem 'pdfkit'

group :development do
  gem 'awesome_print'
  gem 'spring'
  gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-rails'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'rspec-rails', '~> 3.0'
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'webmock'
end

group :production do
  gem 'rails_12factor'
  gem 'wkhtmltopdf-heroku'
end
