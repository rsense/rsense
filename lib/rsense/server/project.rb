module Rsense
  module Server
    class Project
      attr_accessor :name, :path, :graph, :runtime, :loadPath, :gemPath, :loaded

      def initialize(name, path)
        @name = name
        @path = path
        @graph = Rsense::Typing::Graph.new
        @runtime = @graph.getRuntime()
        @loadPath = []
        @gemPath = []
        @loaded = {}
      end

    end
  end
end
