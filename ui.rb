require 'rubygems'
require 'rubygems/package'
require 'bundler/setup'
Bundler.require(:default, :ui)
load 'environment.rb'

module Uphold
  class Ui < ::Sinatra::Base
    include Logging
    set :views, settings.root + '/views'

    helpers do
      def h(text)
        Rack::Utils.escape_html(text)
      end
    end

    before do
      Config.load_engines
      Config.load_transports
      @configs = Config.load_configs
    end

    get '/' do
      erb :index
    end

    get '/run/:slug' do
      if Docker::Image.exist?("#{UPHOLD[:docker_container]}:#{UPHOLD[:docker_tag]}")
        Docker::Image.get("#{UPHOLD[:docker_container]}:#{UPHOLD[:docker_tag]}")
      else
        Docker::Image.create('fromImage' => UPHOLD[:docker_container], 'tag' => UPHOLD[:docker_tag])
      end

      volumes = { }
      UPHOLD[:docker_mounts].flatten.each { |m| volumes[m] = { "#{m}" => 'ro' } }

      # this is a hack for when you're working in development on osx
      volumes[UPHOLD[:config_path]] = { '/etc/uphold' => 'ro' }
      volumes[UPHOLD[:docker_log_path]] = { '/var/log/uphold' => 'rw' }

      # Unix sockets when mounted can't have the protocol at the start
      if UPHOLD[:docker_url].include?('unix://')
        without_protocol = UPHOLD[:docker_url].split('unix://')[1]
        volumes[without_protocol] = { "#{without_protocol}" => 'rw' }
      end

      @container = Docker::Container.create(
        'Image' => "#{UPHOLD[:docker_container]}:#{UPHOLD[:docker_tag]}",
        'Cmd' => [params[:slug] + '.yml'],
        'Volumes' => volumes
      )

      @container.start('Binds' => volumes.map { |v, h| "#{v}:#{h.keys.first}" })
      redirect '/'
    end
  end
end
