require 'rubygems'
require 'rubygems/package'
require 'bundler/setup'
Bundler.require(:default, :ui)
load 'environment.rb'

module Uphold
  class Ui < ::Sinatra::Base
    include Logging

    helpers do
      def h(text)
        Rack::Utils.escape_html(text)
      end
    end

    before do
      Config.load_engines
      Config.load_transports
    end

    get '/' do
      Config.transports.inspect
    end
  end
end
