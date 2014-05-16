require "spoon"
require "jruby-jars"
require "filetree"

module Rsense
  module Client
    class Daemon
      attr_accessor :classpath

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
        rsense_home.join("lib")
      end

      def gem_path
        Gem.path.join(File::PATH_SEPARATOR)
      end

      def java_args
        ["-cp", classpath, "org.jruby.Main"]
      end

      def jruby_args
        ["-cp", classpath, "org.jruby.Main"]
      end

    end
  end
end
