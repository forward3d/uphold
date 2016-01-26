module Uphold
  class Runner
    include Logging
    include Command

    def initialize(config:)
      @name = config.yaml[:name]
      @engine = config.yaml[:engine][:klass]
      @transport = config.yaml[:transport][:klass]
      @config = config.yaml
    end

    def start
      t1 = Time.now
      transport = @transport.new(@config[:transport][:settings])
      engine = @engine.new(@config[:engine][:settings])

      begin
        working_path = transport.fetch
        unless engine.start_container
          touch_state_file('bad_container')
          logger.info 'Backup is BAD'
          exit 0
        end

        if engine.load(path: working_path)
          if @config[:tests].any?
            tests = Tests.new(tests: @config[:tests], ip_address: engine.container_ip_address, port: engine.port, database: engine.database)
            if tests.run
              touch_state_file('ok')
              logger.info 'Backup is OK'
              exit 0
            else
              logger.fatal "Backup for #{@config[:name]} is BAD"
              touch_state_file('bad_tests')
              exit 1
            end
          else
            logger.info 'No tests found, but OK'
            touch_state_file('ok_no_test')
            exit 0
          end
        else
          logger.fatal "Backup for #{@config[:name]} is BAD"
          touch_state_file('bad')
          exit 1
        end
      rescue => e
        logger.error e
        raise e
      ensure
        engine.stop_container
        logger.debug "Removing tmpdir '#{transport.tmpdir}'"
        FileUtils.remove_entry_secure(transport.tmpdir)

        t2 = Time.now
        delta = t2 - t1
        logger.info "Done! (#{format('%.2f', delta)}s)"
      end
    end
  end
end
