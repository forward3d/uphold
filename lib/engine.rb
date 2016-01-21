module Uphold
  class Engine
    include Logging
    include Command
    include Sockets

    attr_reader :port

    def initialize(params)
      @database = params[:database]
      @docker_image = params[:docker_image]
      @docker_tag = params[:docker_tag]
      @container = nil
      @port = nil
    end

    def load(path:)
      logger.info "Engine starting #{self.class}"
      t1 = Time.now
      process = load_backup(path)
      t2 = Time.now
      delta = t2 - t1
      if process.success?
        logger.info "Engine finished successfully (#{format('%.2f', delta)}s)"
        true
      else
        logger.error "Engine failed! (#{format('%.2f', delta)}s)"
        false
      end
    end

    def load_backup
      fail "Your engine must implement the 'load_backup' method"
    end

    def start_container
      if Docker::Image.exist?("#{@docker_image}:#{@docker_tag}")
        logger.debug "Docker image '#{@docker_image}' with tag '#{@docker_tag}' available"
        Docker::Image.get("#{@docker_image}:#{@docker_tag}")
      else
        logger.debug "Docker image '#{@docker_image}' with tag '#{@docker_tag}' does not exist locally, fetching"
        Docker::Image.create('fromImage' => @docker_image, 'tag' => @docker_tag)
      end

      @container = Docker::Container.create('Image' => "#{@docker_image}:#{@docker_tag}")
      @container.start('PortBindings' => { "#{@port}/tcp" => [{ 'HostIp' => '0.0.0.0', 'HostPort' => @port.to_s }] })
      logger.debug "Docker container '#{container_id}' starting"
      wait_for_container_to_be_ready
    end

    def wait_for_container_to_be_ready
      logger.debug "Waiting for Docker container '#{container_id}' to be ready"
      tcp_port_open?(container_id, container_ip_address, port)
    end

    def container_ip_address
      '192.168.99.100'
    end

    def container_id
      @container.id[0..11]
    end

    def stop_container
      logger.debug "Docker container '#{container_id}' stopping"
      @container.stop
    end

  end
end
