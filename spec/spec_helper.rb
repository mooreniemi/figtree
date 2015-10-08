require 'bundler/setup'
Bundler.setup

require 'ostruct'
require 'parslet'
require 'parslet/rig/rspec'

Dir[File.join(File.dirname(__FILE__), "..", "lib" , "**.rb")].each do |file|
  require file
end

RSpec.configure do |config|
end
