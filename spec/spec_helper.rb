#$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'mobile_messenger'
require 'rspec'
require 'webmock/rspec'

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end