require_relative "../../spec_helper"
require 'fileutils'

describe Rsense::Client::Runner do
  before do
    @runner = Rsense::Client::Runner.new
  end

  describe "#ensure_paths_exists" do
    let(:filepath) { "/tmp/rsense-test" }

    before(:each) do
      FileUtils.rm_r(filepath) if File.directory?(filepath)
    end

    after(:each) do
      FileUtils.rm_r(filepath) if File.directory?(filepath)
    end

    it "creates directories when they don't exists" do
      File.directory?(filepath).must_equal(false)
      @runner.ensure_paths_exist(filepath)
      File.directory?(filepath).must_equal(true)
    end

    it "doesn't do anything when directories exists" do
      FileUtils.mkdir_p(filepath)
      File.directory?(filepath).must_equal(true)
      @runner.ensure_paths_exist(filepath)
      File.directory?(filepath).must_equal(true)
    end
  end
end
