require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib rubyrdf]))
RubyRDF.require_all_libs_relative_to(__FILE__, 'support')

begin
  require 'spec/autorun'
rescue LoadError
  require 'rubygems'
  gem 'spec'
  require 'spec/autorun'
end

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

