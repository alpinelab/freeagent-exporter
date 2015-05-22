require "codeclimate-test-reporter"
CodeClimate::TestReporter.start do
  add_filter "/config/initializers/"
end

require 'webmock/rspec'
WebMock.disable_net_connect! allow: %w{codeclimate.com pullreview.com}

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
