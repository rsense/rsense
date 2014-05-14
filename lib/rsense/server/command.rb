require "pathname"
require_relative "./listeners/find_definition_event_listener"
require_relative "./listeners/where_event_listener"

module Rsense
  module Server
    Context = Struct.new(:project, :typeSet, :main, :feature, :loadPathLevel) {
      def clear
        @project = nil
        @typeSet = nil
        @main = false
        @feature = nil
        @loadPathLevel = 0
      end
    }

    class Command
      TYPE_INFERENCE_METHOD_NAME = Rsense::CodeAssist::TYPE_INFERENCE_METHOD_NAME
      FIND_DEFINITION_METHOD_NAME_PREFIX = Rsense::CodeAssist::FIND_DEFINITION_METHOD_NAME_PREFIX
      PROJECT_CONFIG_NAME = ".rsense"
      attr_accessor :context, :options, :parser, :projects, :sandbox, :definitionFinder, :whereListener

      def initialize(options)
        @context = Context.new
        @options = options
        clear()
      end

      def open_project(project)
        @projects[project.name] = project
      end

      def clear
        @parser = Rsense::Server::Parser.new
        @context.clear()
        @projects = {}
        @sandbox = Rsense::Server::Project.new("(sandbox)", Pathname.new("."))
        @sandbox.loadPath = @options.getLoadPath
        @sandbox.gemPath = @options.getGemPath
        @definitionFinder = Rsense::Server::Listeners::FindDefinitionEventListener.new(@context)
        @whereListener = Rsense::Server::Listeners::WhereEventListener.new(@context)
        open_project(@sandbox)
      end

    end
  end
end
