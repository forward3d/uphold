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
      engine = @engine.new(@config[:engine])

      begin
        working_path = transport.fetch
        engine.start_container

        if engine.load(path: working_path)
          if @config[:tests].any?
            tests = Tests.new(tests: @config[:tests], ip_address: engine.container_ip_address, port: engine.port)
            if tests.run
              logger.info 'Backup is OK'
            else
              logger.fatal "Backup for #{@config[:name]} is BAD"
            end
          else
            logger.info 'No tests found, but OK'
          end
        else
          logger.fatal "Backup for #{@config[:name]} is BAD"
        end

        t2 = Time.now
        delta = t2 - t1
        logger.info "Done! (#{format('%.2f', delta)}s)"
      ensure
        engine.stop_container
        logger.debug "Removing tmpdir '#{transport.tmpdir}'"
        FileUtils.remove_entry_secure(transport.tmpdir)
      end
    end
  end
end
