module Uphold
  require 'rubygems'
  require 'rubygems/package'
  require 'bundler/setup'
  Bundler.require(:default, :tester)
  load 'environment.rb'

  Config.load_engines
  Config.load_transports

  run = Runner.new(config: Uphold::Config.new(ARGV[0]))
  run.start
end
