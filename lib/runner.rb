module Uphold
  class Runner
    include Logging

    def initialize(config:)
      @name = config[:name]
      @engine = config[:engine][:klass]
      @transport = config[:transport][:klass]
      @config = config
    end

    def start
      transport_params = @config[:transport][:settings]
      transport_params.merge!(dir: Dir.mktmpdir)
      transport = @transport.new(transport_params)

      engine_params = @config[:engine]
      engine_params.delete(:type)
      engine_params.delete(:klass)
      engine_params.merge!(path: transport.fetch)

      engine = @engine.new(engine_params)
      engine.load
    end

  end
end
