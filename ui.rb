require 'rubygems'
require 'rubygems/package'
require 'bundler/setup'
Bundler.require(:default, :ui)
load 'environment.rb'

module Uphold
  class Ui < ::Sinatra::Base
    include Logging
    set :views, settings.root + '/views'
    set :public_folder, settings.root + '/public'

    helpers do
      def h(text)
        Rack::Utils.escape_html(text)
      end

      def epoch_to_datetime(epoch)
        Time.at(epoch).utc.to_datetime
      end
    end

    before do
      Config.load_engines
      Config.load_transports
      @configs = Config.load_configs
    end

    get '/' do
      @logs = logs
      erb :index
    end

    get '/run/:slug' do
      start_docker_container(params[:slug])
      redirect '/'
    end

    get '/logs/:filename' do
      @log = File.join('/var/log/uphold', params[:filename])
      erb :log
    end

    private

    def start_docker_container(slug)
      if Docker::Image.exist?("#{UPHOLD[:docker_container]}:#{UPHOLD[:docker_tag]}")
        Docker::Image.get("#{UPHOLD[:docker_container]}:#{UPHOLD[:docker_tag]}")
      else
        Docker::Image.create('fromImage' => UPHOLD[:docker_container], 'tag' => UPHOLD[:docker_tag])
      end

      volumes = {}
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
        'Cmd' => [slug + '.yml'],
        'Volumes' => volumes,
        'Env' => ["UPHOLD_LOG_FILENAME=#{Time.now.to_i}_#{slug}"]
      )

      @container.start('Binds' => volumes.map { |v, h| "#{v}:#{h.keys.first}" })
    end

    def logs
      logs = {}
      raw_test_logs.each do |log|
        epoch = log.split('_')[0]
        config = log.split('_')[1].gsub!('.log', '')
        state = raw_state_files.find { |s| s.include?("#{epoch}_#{config}") }
        if state
          state = state.gsub("#{epoch}_#{config}", '')[1..-1]
        else
          state = 'running'
        end
        logs[config] ||= []
        logs[config] << { epoch: epoch.to_i, state: state, filename: log }
        logs[config].sort_by! { |h| h[:epoch].to_i }.reverse!
      end
      logs
    end

    def raw_test_logs
      raw_files.select { |file| File.extname(file) == '.log' }
    end

    def raw_state_files
      raw_files.select { |file| File.extname(file) == '' }
    end

    def raw_files
      Dir[File.join('/var/log/uphold', '*')].select { |log| File.basename(log) =~ /^[0-9]{10}/ }.map { |file| File.basename(file) }
    end
  end
end
