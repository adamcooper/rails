require 'rails/engine'

module Rails
  class Plugin < Engine
    def self.inherited(base)
      raise "You cannot inherit from Rails::Plugin"
    end

    # TODO Right now, if a plugin has an Engine or a Railtie inside it,
    # the initializers for this plugin will be executed twice.
    def self.all(list, paths)
      plugins = []
      paths.each do |path|
        Dir["#{path}/*"].each do |plugin_path|
          plugin = new(plugin_path)
          next unless list.include?(plugin.name) || list.include?(:all)
          plugins << plugin
        end
      end

      plugins.sort_by do |p|
        [list.index(p.name) || list.index(:all), p.name.to_s]
      end
    end

    attr_reader :name, :path

    def initialize(root)
      @name = File.basename(root).to_sym
      config.root = root
    end

    def config
      @config ||= Engine::Configuration.new
    end

    initializer :load_init_rb do |app|
      file   = Dir["#{root}/{rails/init,init}.rb"].first
      config = app.config
      eval(File.read(file), binding, file) if file && File.file?(file)
    end
  end
end
