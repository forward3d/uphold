module Uphold
  class Runner
    include Logging
    include Command

    def initialize(config:)
      @name = config[:name]
      @engine = config[:engine][:klass]
      @transport = config[:transport][:klass]
      @config = config
    end

    def start
      transport_params = @config[:transport][:settings]
      transport = @transport.new(transport_params)
      working_path = transport.fetch

      engine_params = @config[:engine]
      engine_params.delete(:type)
      engine_params.delete(:klass)
      engine_params.merge!(path: working_path)
      engine = @engine.new(engine_params)

      if engine.load
        if @config[:tests].any?
          tests = Tests.new(@config[:tests])
          if tests.run
            logger.info 'Backup is OK'
          else
            logger.fatal 'Backup is BAD'
          end
        else
          logger.info 'No tests found, but OK'
        end
      else
        logger.fatal 'Backup is BAD'
      end

      logger.info 'Done!'
    end
  end
end
