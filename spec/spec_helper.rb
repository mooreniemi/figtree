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

# because we raise more than one error type from invalid
# this should prob be avoided though
RSpec::Expectations.configuration.warn_about_potential_false_positives = false

RSpec.configure do |config|
  # quiet output from figtree_spec invalid ini context
  config.before { allow($stderr).to receive(:puts) }
end
