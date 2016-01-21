module Uphold
  class Tests
    include Logging
    include Command

    def initialize(ip_address:, port:, tests:)
      @ip_address = ip_address
      @port = port
      @tests = tests
    end

    def run
      logger.info 'Tests starting'

      outcomes = @tests.collect do |t|
        process = run_command("UPHOLD_IP=#{@ip_address} UPHOLD_PORT=#{@port} ruby tests/#{t}", 'ruby')
        if process.success?
          logger.info "Test #{t} finished successfully"
          true
        else
          logger.error "Test #{t} did NOT finish successfully"
          false
        end
      end

      logger.info 'Tests finished'
      !outcomes.include?(false)
    end
  end
end
