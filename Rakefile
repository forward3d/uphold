$stdout.sync = true

require 'rubygems'
require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] ||= 'development'

require 'sinatra/activerecord/rake'

namespace :db do
  task :load_config do
    require "./ui"
  end
end
