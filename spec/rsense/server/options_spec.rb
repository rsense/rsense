require "pathname"
require "json"
require_relative "../../spec_helper"

describe Rsense::Server::Options do
  before do
    @json_path = Pathname.new("spec/fixtures/sample.json")
    @json = JSON.parse(@json_path.read)
    @options = Rsense::Server::Options.new(@json)
  end

  it "has a command" do
    @options.command.must_match("code_completion")
  end
end
