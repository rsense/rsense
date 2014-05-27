require "pathname"
require "json"
require_relative "../../spec_helper"

describe Rsense::Server::Code do
  describe "type inference" do

    before do
      @json_path = Pathname.new("spec/fixtures/sample.json")
      @json = JSON.parse(@json_path.read)
      @code = Rsense::Server::Code.new(@json["code"])
      @location = @json["location"]
    end

    it "has an array of lines" do
      @code.lines.size.must_equal(4)
      @code.lines.last.must_match(/hello/)
    end

    it "injects the type inference marker" do
      @code.inject_inference_marker(@location).must_match(/testarg\.__rsense_type_inference__/)
    end

    it "does not duplicate the dot accessor" do
      code = Rsense::Server::Code.new("def check(testar)\n  testar.\nend\ncheck('hello')")
      code.inject_inference_marker(@location).wont_match(/testar\.\.__rsense_type_inference__/)
      code.inject_inference_marker(@location).must_match(/testar\.__rsense_type_inference__/)
    end
  end

  describe "find definition" do
    before do
      @json_path = Pathname.new("spec/fixtures/find_def_sample.json")
      @json = JSON.parse(@json_path.read)
      @code = Rsense::Server::Code.new(@json["code"])
      @location = @json["location"]
    end

    it "injects the find definition marker" do
      marker = "#{Rsense::Server::Code::FIND_DEFINITION_METHOD_NAME_PREFIX}0"
      @code.inject_definition_marker(marker, @location).must_match(/__rsense_find_definition__0TestThings/)
    end
  end
end
