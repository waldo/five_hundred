# encoding: UTF-8
require "rspec"
require "five_hundred"
require "five_hundred/ai"

Dir["./spec/support/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
end