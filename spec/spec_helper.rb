require "minitest/autorun"
require "minitest/reporters"
Minitest::Reporters.use!

require_relative "../lib/rsense/client/daemon.rb"
require_relative "../lib/rsense/server/gem_path.rb"
require_relative "../lib/rsense/server/load_path.rb"
