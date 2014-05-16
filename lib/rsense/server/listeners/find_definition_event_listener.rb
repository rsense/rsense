require "set"

module Rsense
  module Server
    module Listeners

    end
  end
end

class Rsense::Server::Listeners::FindDefinitionEventListener
  include Java::org.cx4a.rsense::Project::EventListener

  EventType = Rsense::Typing::Graph::EventListener::EventType
  SourceLocation = Rsense::Util::SourceLocation

  attr_accessor :prefix, :locations, :context

  def initialize(context)
    @context = context
    @@counter = 0
    @locations = Set.new
  end

  def setup
    @locations.clear
    @prefix = Rsense::Server::Command::FIND_DEFINITION_METHOD_NAME_PREFIX + @@counter
  end

  def self.counter
    old = @@counter
    @@counter += 1
    return old
  end

  def getLocations
    @locations
  end

  def update(event)
    vertex = event.vertex
    if check_vertex(vertex)
      realName = vertex.getName().substring(@prefix.length)
      receivers = vertex.getReceiverVertex().getTypeSet()
      receivers.each do |receiver|

        receiver_type = receiver.getMetaClass()
        if receiver_type
          location = nil
          method = receiver_type.search_method(realName)
          if method
            @locations.add(method.getLocation) if method.getLocation
          else
            klass = nil
            if receiver_type instance_of? Rsense::Ruby::MetaClass
              metaClass = receiver_type
              if metaClass.getAttached instance_of? Rsense::Ruby::RubyModule
                klass = metaClass.getAttached
              end
            else
              klass = @context.project.graph().getRuntime().getContext().getCurrentScope().getModule()
            end
            if klass
              constant = klass.getConstant(realName)
              if constant instance_of? Rsense::Typing::Runtime::VertexHolder
                location = SourceLocation.of(constant.getVertex().getNode())
              elsif constant instance_of? Rsense::Ruby::RubyModule
                  location = constant.getLocation()
              end
            end
          end

          if location
            @locations.add(location)
          end

        end
      end
      vertex.cutout()
    end
  end

  def check_vertex(vertex)
    if @context.main && event.type == EventType::METHOD_MISSING
      if vertex && vertex.getName().startsWith(@prefix) && vertex.getReceiverVertex()
        return true
      end
    end
  end

end
