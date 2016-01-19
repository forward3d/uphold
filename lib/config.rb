module Uphold
  class Config
    def self.all
      Dir[File.join(ROOT, 'config', '*.yml')].sort.map { |file| load_if_active?(file) }.compact
    end

    private

    def self.load_if_active?(file)
      yaml = YAML.load_file(file)
      yaml if yaml['enabled']
    end
  end
end
