require 'rubygems'
require 'bundler/setup'
Bundler.require
require 'yaml'

ENV['RACK_ENV'] ||= 'development'

ROOT = File.dirname(File.expand_path(__FILE__))

Dir["#{ROOT}/lib/helpers/*.rb"].sort.each { |file| require file }
Dir["#{ROOT}/lib/*.rb"].sort.each { |file| require file }

Uphold::Config.load_engines
Uphold::Config.load_transports
