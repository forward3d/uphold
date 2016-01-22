module Uphold
  class Config
    require 'yaml'
    include Logging

    attr_reader :yaml

    def initialize(config)
      fail unless config
      yaml = YAML.load_file(File.join('/etc', 'uphold', 'conf.d', config))
      @yaml = Config.deep_convert(yaml)
      fail unless valid?
      logger.info "Loaded config '#{@yaml[:name]}' from '#{config}'"
      @yaml = supplement
    end

    def valid?
      valid = true
      valid = false if @yaml[:enabled] != true
      valid = false unless Config.engines.any? { |e| e[:name] == @yaml[:engine][:type] }
      valid = false unless Config.transports.any? { |e| e[:name] == @yaml[:transport][:type] }
      valid
    end

    def supplement
      @yaml[:engine][:klass] = Config.engines.find { |e| e[:name] == @yaml[:engine][:type] }[:klass]
      @yaml[:transport][:klass] = Config.transports.find { |e| e[:name] == @yaml[:transport][:type] }[:klass]
      @yaml
    end

    def self.load_global
      yaml = YAML.load_file(File.join('/', 'etc', 'uphold', 'uphold.yml'))
      yaml = deep_convert(yaml)
      yaml[:log_level] ||= 'INFO'
      yaml[:docker_url] ||= 'unix:///var/run/docker.sock'
      yaml
    end

    def self.load_engines
      [Dir["#{ROOT}/lib/engines/*.rb"], Dir['/etc/uphold/engines/*.rb']].flatten.uniq.sort.each do |file|
        require file
        basename = File.basename(file, '.rb')
        add_engine name: basename, klass: Object.const_get("Uphold::Engines::#{File.basename(file, '.rb').capitalize}")
      end
    end

    def self.engines
      @engines ||= []
    end

    def self.add_engine(engine)
      list = engines
      list << engine
      logger.debug "Loaded engine #{engine[:klass]}"
      list.uniq! { |e| e[:name] }
    end

    def self.load_transports
      [Dir["#{ROOT}/lib/transports/*.rb"], Dir['/etc/uphold/transports/*.rb']].flatten.uniq.sort.each do |file|
        require file
        basename = File.basename(file, '.rb')
        add_transport name: basename, klass: Object.const_get("Uphold::Transports::#{File.basename(file, '.rb').capitalize}")
      end
    end

    def self.add_transport(transport)
      list = transports
      list << transport
      logger.debug "Loaded transport #{transport[:klass]}"
      list.uniq! { |e| e[:name] }
    end

    def self.transports
      @transports ||= []
    end

    private

    def self.deep_convert(element)
      return element.collect { |e| deep_convert(e) } if element.is_a?(Array)
      return element.inject({}) { |sh,(k,v)| sh[k.to_sym] = deep_convert(v); sh } if element.is_a?(Hash)
      element
    end
  end
end
