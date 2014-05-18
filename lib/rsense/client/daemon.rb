require "forwardable"
require "jruby-jars"
require "filetree"
require_relative "./runner"

module Rsense
  module Client
    class Daemon
      extend Forwardable
      attr_accessor :classpath, :external_args, :argslist, :rsense_home, :rsense_lib, :runner

      def_delegators :@runner, :start, :stop, :restart

      def initialize(args=[])
        @external_args = args
        @rsense_home = rsense_home
        @rsense_lib = rsense_lib
        @argslist = build_argslist()
        @runner = Rsense::Client::Runner.new(@argslist)
        set_gem_path_env(gem_path)
      end

      def build_argslist
        java_args + jruby_args(@external_args)
      end

      def classpath
        @classpath ||= [
            JRubyJars.core_jar_path,
            JRubyJars.stdlib_jar_path
          ].join(File::PATH_SEPARATOR)
      end

      def rsense_home
        localpath = FileTree.new(__FILE__).expand_path
        localpath.ancestors.reject { |f|
           f.to_s =~ /rsense.*\/lib/
        }.first
      end

      def rsense_lib
        @rsense_home.join("lib")
      end

      def gem_path
        Gem.path.join(File::PATH_SEPARATOR)
      end

      def set_gem_path_env(gp)
        ENV["GEM_PATH"] = gp
      end

      def java_args
        ["java", "-cp", classpath, "org.jruby.Main"]
      end

      def jruby_args(cli_args=[])
        cli_args ||= ""
        ["-I#{@rsense_lib}", "bin/_rsense.rb"] + cli_args
      end

    end
  end
end
