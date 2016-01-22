module Uphold
  require 'rubygems'
  require 'rubygems/package'
  require 'bundler/setup'
  Bundler.require

  ROOT = File.dirname(File.expand_path(__FILE__))
  Dir["#{ROOT}/lib/helpers/*.rb"].sort.each { |file| require file }
  Dir["#{ROOT}/lib/*.rb"].sort.each { |file| require file }

  @config = Config.load_global

  include Logging
  logger.level = Logger.const_get(@config[:log_level])
  logger.info 'Starting Uphold'

  Docker.url = @config[:docker_url]
  logger.debug "Docker URL - '#{Docker.url}'"
end
