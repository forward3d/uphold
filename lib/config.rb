module Uphold
  class Config
    def self.all
      Dir[File.join(ROOT, 'config', '*.yml')].sort.map do |config|
        yaml = YAML.load_file(config)
        next unless valid?(yaml)
        supplement(yaml)
      end.compact
    end

    def self.valid?(yaml)
      valid = true
      valid = false if yaml['enabled'] != true
      valid = false unless engines.any? { |e| e[:name] == yaml['engine']['type'] }
      valid = false unless transports.any? { |e| e[:name] == yaml['transport']['type'] }
      valid
    end

    def self.supplement(yaml)
      yaml['engine']['klass'] = engines.find { |e| e[:name] == yaml['engine']['type'] }[:klass]
      yaml['transport']['klass'] = transports.find { |e| e[:name] == yaml['transport']['type'] }[:klass]
      yaml
    end

    def self.load_engines
      Dir["#{ROOT}/lib/engines/*.rb"].sort.each do |file|
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
      list.uniq! { |e| e[:name] }
    end

    def self.load_transports
      Dir["#{ROOT}/lib/transports/*.rb"].sort.each do |file|
        require file
        basename = File.basename(file, '.rb')
        add_transport name: basename, klass: Object.const_get("Uphold::Transports::#{File.basename(file, '.rb').capitalize}")
      end
    end

    def self.add_transport(transport)
      list = transports
      list << transport
      list.uniq! { |e| e[:name] }
    end

    def self.transports
      @transports ||= []
    end
  end
end
