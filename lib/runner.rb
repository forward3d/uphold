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
      logger.info "Starting transport #{@transport}"
      transport = @transport.new(transport_params)

      engine_params = @config[:engine]
      engine_params.delete(:type)
      engine_params.delete(:klass)
      engine_params.merge!(path: transport.fetch)
      logger.info "Starting engine #{@engine}"
      engine = @engine.new(engine_params)

      if engine.load
        # tests
      end
    end

  end
end
