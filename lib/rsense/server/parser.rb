module Rsense
  module Server
    class Parser
      include JRubyParser

      def parse_string(source_string, filename='')
        filename = filename || '(string)'
        version = org.jrubyparser.CompatVersion::RUBY2_0
        opts = { filename: filename, version: version }
        parse(source_string, opts)
      end

    end
  end
end
