require_relative "../../spec_helper.rb"

describe Rsense::Server::GemPath do

  it "returns the list of Gem paths" do
    Rsense::Server::GemPath.stub :fetch, ["/path/to/the/gems"] do
      Rsense::Server::GemPath.paths.first.must_match(/\/path\/to\/the\/gems/)
    end
  end

  it "excludes paths inside jruby\'s jars" do
    Rsense::Server::GemPath.stub :fetch, ["file: file in a jar"] do
      Rsense::Server::GemPath.paths.wont_include("file: file in a jar")
    end
  end
end
