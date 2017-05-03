require 'simplecov'

# Configure SimpleCov
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter
])

SimpleCov.start do
  add_filter do |source_file|
    source_file.filename.to_s.include?('test')
  end
end


ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end


def wrapped_params(params)
  if rails_4?
    params
  elsif rails_5?
    { params: params }
  end
end


def rails_4?
  Rails.version[0] == '4'
end


def rails_5?
  Rails.version[0] == '5'
end
