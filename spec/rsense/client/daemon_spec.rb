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
    mhome.to_s.must_match(/rsense$/)
  end
end
