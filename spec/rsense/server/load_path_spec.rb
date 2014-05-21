require "pathname"
require_relative "../../spec_helper.rb"

describe Rsense::Server::LoadPath do
  it "lists loads paths" do
    Rsense::Server::LoadPath.stub :fetch,["/some/path/to/load"] do
      Rsense::Server::LoadPath.paths.first.must_match(/\/some\/path\/to\/load/)
    end
  end

  it "does not list paths inside a jar" do
    Rsense::Server::LoadPath.stub :fetch, ["file:path/in/jar"] do
      Rsense::Server::LoadPath.paths.wont_include("file:path/in/jar")
    end
  end

  describe "with project" do
    ProjectMock = Struct.new(:path)

    before do
      @proj_path = "spec/fixtures/load_path_fixture"
      @project = ProjectMock.new(@proj_path)
    end

    it "checks for a Gemfile.lock" do
      Rsense::Server::LoadPath.find_gemfile(@project).to_s.must_match(/Gemfile/)
    end

    it "checks paths for correct version" do
      fake_paths = ["1", "2", "3"]
      checked = Rsense::Server::LoadPath.check_version(fake_paths, "2")
      checked.size.must_equal(1)
      checked.must_include("2")
      checked.wont_include("1")
      checked.wont_include("3")
    end

    it "returns a list of Gems" do
      class SpecMock
        def name
          "mock"
        end

        def version
          "2"
        end
      end

      lfile = Object.new

      def lfile.specs
        [SpecMock.new]
      end

      Gem.stub :find_files, ["/stubbed/path-2"] do
        ret_gems = Rsense::Server::LoadPath.gem_info(lfile).first
        ret_gems.name.must_match(/mock/)
        ret_gems.full_name.must_match(/mock-2/)
        ret_gems.path.first.must_match(/stubbed/)
      end
    end
  end
end
