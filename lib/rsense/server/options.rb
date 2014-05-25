require "pathname"
require "set"
require "json"

module Rsense
  module Server
    class Options
      attr_accessor :load_path, :gem_path, :rest, :command, :location, :log, :log_level, :debug, :project, :dependencies, :name, :prefix, :config, :code, :file

      def initialize(opts)
        @rest = []
        @command = opts["command"]
        parse_args(opts)
      end

      def parse_args(opts)
        opts.each_pair do |k, v|
          if respond_to?("#{k}=")
            __send__("#{k}=", v)
          else
            @rest.push(v)
          end
        end
      end

      def here_doc_reader(reader)
        Rsense::Util::HereDocReader.new(reader, "EOF")
      end

      def debug?
        @debug
      end

      def log_level
        if debug?
          Rsense::Util::Logger::Level::DEBUG
        end
        level = @log_level
        if level
          Rsense::Util::Logger::Level.valueOf(level.upcase)
        else
          Rsense::Util::Logger::Level::MESSAGE
        end
      end

      def progress
        if @progress
          @progress.to_i
        else
          0
        end
      end

      def load_path
        @load_path = @load_path || Rsense::Server::LoadPath.paths
      end

      def gem_path
        @gem_path = @gem_path || Rsense::Server::GemPath.paths
      end

      def dependencies
        return @dependencies if @dependencies
        if @project
          Rsense::Server::LoadPath.dependencies(@project)
        else
          nil
        end
      end

      def project=(path)
        @project = Pathname.new(path).expand_path
      end

      def inherit(parent)
        if parent.debug?
          @debug = true
        end
        @log = parent.log()
        @log_level = parent.log_level
        @load_path = parent.load_path
        @gem_path = parent.gem_path
      end

      def load_config(config)
        path = Pathname.new(config).expand_path
        if path.exist?
          json = JSON.parse(path.read)
          parse_args(json)
        else
          puts "Config file: #{path} does not exist"
        end
      end

    end
  end
end

