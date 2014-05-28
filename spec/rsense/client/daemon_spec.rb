require_relative "../../spec_helper"

describe Rsense::Client::Daemon do

  before do
    @daemon = Rsense::Client::Daemon.new
  end

  it "returns the paths to the JRuby Jars" do
    cp = @daemon.classpath
    cp.must_match(/jruby-core-complete/)
    cp.must_match(/jruby-stdlib-complete/)
  end

  it "knows where home is" do
    mhome = @daemon.rsense_home
    mhome.to_s.must_match(/rsense-server$/)
  end

  it "knows where the lib dir is" do
    @daemon.rsense_lib.to_s.must_match(/rsense.*\/lib/)
  end

  it "passes args to the JVM" do
    @daemon.java_args.last.must_match(/Main/)
  end

  it "passes args to JRuby" do
    @daemon.jruby_args(["foo", "bar"]).last.must_match(/bar/)
  end

  it "knows where the GEM_PATH is" do
    @daemon.gem_path.must_match(/gem/)
  end

  describe "with args passed on init" do
    before do
      @daemon = Rsense::Client::Daemon.new(["foo", "bar"])
    end

    it "combines args for the JVM and JRuby" do
      @daemon.build_argslist.must_include("java")
    end
  end

  it "sets the GEM_PATH env" do
    gp = @daemon.gem_path
    @daemon.set_gem_path_env(gp)
    ENV["GEM_PATH"].must_equal gp
  end

  describe "Runner" do
    class RunnerStub
      attr_accessor :exec_cmd, :false

      def initialize(exec_cmd)
        @exec_cmd = exec_cmd
        @called = false
      end

      def start
        @called = true
      end

      def stop
        @called = true
      end

      def restart
        @called = true
      end
    end

    it "should initialize a runner" do
      daemon = Rsense::Client::Daemon.new(["foo", "bar"])
      daemon.runner.class::PID_PATH.must_match(/tmp\/exec\.pid/)
    end

    it "should delegate start method to runner" do
      daemon = Rsense::Client::Daemon.new(["foo", "bar"])
      daemon.runner = RunnerStub.new(daemon.argslist)
      daemon.start.must_equal(true)
    end

    it "should delegate stop method to runner" do
      daemon = Rsense::Client::Daemon.new(["foo", "bar"])
      daemon.runner = RunnerStub.new(daemon.argslist)
      daemon.stop.must_equal(true)
    end

    it "should delegate stop method to runner" do
      daemon = Rsense::Client::Daemon.new(["foo", "bar"])
      daemon.runner = RunnerStub.new(daemon.argslist)
      daemon.restart.must_equal(true)
    end

  end

end
