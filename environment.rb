module Uphold
  require 'rubygems'
  require 'rubygems/package'
  require 'bundler/setup'
  Bundler.require(:default)

  ROOT = File.dirname(File.expand_path(__FILE__))
  Dir["#{ROOT}/lib/helpers/*.rb"].sort.each { |file| require file }
  Dir["#{ROOT}/lib/*.rb"].sort.each { |file| require file }

  UPHOLD = Config.load_global

  include Logging
  logger.level = Logger.const_get(UPHOLD[:log_level])
  logger.info 'Starting Uphold'

  Docker.url = UPHOLD[:docker_url]
  logger.debug "Docker URL - '#{Docker.url}'"
end
