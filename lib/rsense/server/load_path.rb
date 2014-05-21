require "pathname"

module Rsense
  module Server
    module LoadPath

      Dependency = Struct.new(:name, :full_name, :path)

      module_function
      def paths
        fetch.map { |p| p unless p =~ /^file:/ }
      end

      def fetch
        $LOAD_PATH
      end

      def dependencies(project)
        @gemfile = find_gemfile(project)
        if @gemfile
          lockfile = Bundler::LockfileParser.new(Bundler.read_file(@gemfile))
          gem_info(lockfile)
        end
      end

      def gem_info(lfile)
        lfile.specs.map do |s|
          generate_struct(s.name, s.version)
        end
      end

      def generate_struct(name, version)
        paths = check_version(Gem.find_files(name), version)
        Dependency.new(name, "#{name}-#{version.to_s}", paths)
      end

      def check_version(gem_paths, version)
        gem_paths.select do |p|
          p.to_s =~ /#{version}/
        end
      end

      def find_gemfile(project)
        pth = Pathname.new(project.path()).expand_path
        Dir.glob(pth.join("**/Gemfile.lock")).first
      end

    end
  end
end
