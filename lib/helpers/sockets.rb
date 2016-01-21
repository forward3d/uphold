module Uphold
  module Sockets
    module_function

    require 'socket'
    require 'timeout'

    def tcp_port_open?(host, port, timeout = 10, sleep_period = 0.5)
      Timeout.timeout(timeout) do
        begin
          s = TCPSocket.new(host, port)
          s.close
          logger.info "Docker container #{host}:#{port} ready!"
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          logger.debug "Docker container #{host}:#{port} not open yet"
          sleep(sleep_period)
          retry
        end
      end
    rescue Timeout::Error
      logger.debug "Docker container #{host}:#{port} did not open port in a timely manner"
      return false
    end
  end
end
