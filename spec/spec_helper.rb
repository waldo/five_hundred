ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

require "rspec"

Dir[File.join(ROOT, "lib/*.rb")].each { |f| require f }
Dir[File.join(ROOT, "spec/shared/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
end