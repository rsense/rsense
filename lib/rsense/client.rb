require_relative "client/daemon"

module Rsense
  class Client
    attr_accessor :config

    Config = Struct.new(
      :gem_home,
      :gem_path,
      :load_path
    )

    def gather_info
      @config = Config.new(gem_home, gem_path, $:.join(File::PATH_SEPARATOR))
    end

    def gem_home
      ENV["GEM_HOME"]
    end

    def gem_path
      gem_pth = ENV["GEM_PATH"]
      gem_pth.concat(Gem.path)
      gem_pth.join(File::PATH_SEPARATOR)
    end

  end
end
