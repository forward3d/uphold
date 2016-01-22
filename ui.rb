module Uphold
  require 'rubygems'
  require 'rubygems/package'
  require 'bundler/setup'
  Bundler.require(:default, :ui)
  load 'environment.rb'

  class Ui < Sinatra::Base
    include Logging

    before do
      Config.load_engines
      Config.load_transports
    end

    get '/' do
      Config.engines.inspect
      # 'Hello from docker!'
    end
  end
end
