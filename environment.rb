module Uphold
  require 'rubygems'
  require 'rubygems/package'
  require 'bundler/setup'
  Bundler.require

  ROOT = File.dirname(File.expand_path(__FILE__))
  Dir["#{ROOT}/lib/helpers/*.rb"].sort.each { |file| require file }
  Dir["#{ROOT}/lib/*.rb"].sort.each { |file| require file }

  include Logging
  logger.level = Logger::DEBUG
  logger.info 'Starting Uphold'
  logger.debug "Docker info - #{Docker.version}"

  Config.load_engines
  Config.load_transports

  run = Runner.new(config: Uphold::Config.new(ARGV[0]))
  run.start
end
