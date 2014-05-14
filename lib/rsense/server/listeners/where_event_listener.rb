module Rsense
  module Server
    module Listeners

    end
  end
end

class Rsense::Server::Listeners::WhereEventListener
  include Rsense::Project::EventListener

  EventType = Rsense::Typing::Graph::EventListener::EventType
  SourceLocation = Rsense::Util::SourceLocation

  attr_accessor :line, :closest, :name, :context

  def initialize(context)
    @context = context
  end

  def prepare(line)
    @line = line
  end

  def update(event)
    eligible = [ EventType::DEFINE, EventType::CLASS, EventType::MODULE ]
    if context.main && eligible.any? {|e| event.type == e}
      if event.name && event.node
        loc = SourceLocation.of(event.node)
        loc_line = loc.getLine()
        if loc && @line >= loc_line && @line - @closest > @line - loc_line
          @closest = loc_line
          @name = event.name
        end
      end
    end
  end

end
