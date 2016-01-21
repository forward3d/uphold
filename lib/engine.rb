module Uphold
  class Engine
    include Logging
    include Command

    def initialize(params)
      @database = params[:database]
      @docker_image = params[:docker][:image]
      @docker_tag = params[:docker][:tag]
      @container = nil
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
        image = Docker::Image.get("#{@docker_image}:#{@docker_tag}")
      else
        logger.debug "Docker image '#{@docker_image}' with tag '#{@docker_tag}' does not exist locally, fetching"
        image = Docker::Image.create('fromImage' => @docker_image, 'tag' => @docker_tag)
      end
      @container = image.run
      logger.debug "Docker container '#{@container.id[0..11]}' starting"
    end

    def stop_container
      logger.debug "Docker container '#{@container.id[0..11]}' stopping"
      @container.stop
    end
  end
end
