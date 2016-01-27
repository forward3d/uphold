module Uphold
  module Sockets
    module_function

    require 'socket'
    require 'timeout'

    def tcp_port_open?(name, host, port, timeout = 10, sleep_period = 2.0)
      Timeout.timeout(timeout) do
        begin
          s = TCPSocket.new(host, port)
          s.close
          logger.info "Docker container '#{name}' ready!"
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          logger.warn "Docker container '#{name}' port is #{port} not open yet"
          sleep(sleep_period)
          retry
        end
      end
    rescue Timeout::Error
      logger.error "Docker container '#{name}' port #{port} did not open port in a timely manner"
      return false
    end
  end
end
