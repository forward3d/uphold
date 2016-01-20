module Uphold
  require 'rubygems'
  require 'rubygems/package'
  require 'bundler/setup'
  Bundler.require
  require 'yaml'
  require 'open3' 

  ENV['RACK_ENV'] ||= 'development'

  ROOT = File.dirname(File.expand_path(__FILE__))

  Dir["#{ROOT}/lib/helpers/*.rb"].sort.each { |file| require file }
  Dir["#{ROOT}/lib/*.rb"].sort.each { |file| require file }

  include Logging

  logger.info 'Starting Uphold'

  Config.load_engines
  Config.load_transports

  run = Runner.new(config: Uphold::Config.all.first)
  puts run.inspect
  run.start

end
