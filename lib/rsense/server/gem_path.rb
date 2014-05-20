module Rsense
  module Server
    module GemPath

      module_function
      def paths
        fetch.map do |p|
          p unless p =~ /^file:/
        end
      end

      def fetch
        Gem.path
      end

    end
  end
end
