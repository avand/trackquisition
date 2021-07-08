class Config
  class << self
    attr_accessor :config

    def init
      @config = YAML.load_file 'config.yml'
    end

    def [](key)
      config[key]
    end
  end
end
