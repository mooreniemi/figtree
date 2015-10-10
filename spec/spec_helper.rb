require 'bundler/setup'
Bundler.setup

require 'pry'
require 'ostruct'
require 'parslet'
require 'parslet/rig/rspec'
require 'parslet/convenience'

require 'simplecov'
SimpleCov.start

Dir[File.join(File.dirname(__FILE__), "..", "lib" , "**.rb")].each do |file|
  require file
end

RSpec.configure do |config|
  # quiet output from figtree_spec invalid ini context
  config.before { allow($stderr).to receive(:puts) }
end
