require 'fileutils'
require 'rubygems'
require 'spoon'

module Rsense
  module Client
    class Runner
      attr_accessor :args

      APPNAME = 'rsense'
      WORK_PATH = Dir.pwd
      # TODO: Make this configurable w/out ENV variables
      PID_PATH  = ENV['RSENSE_PID'] || '/tmp'
      OUT_PATH = ENV['RSENSE_LOG'] || '/tmp'
      EXEC = "/usr/bin/env"

      def initialize(args={})
        ensure_paths_exist(PID_PATH, OUT_PATH)
        @args = args
      end

      def self.get_pid
        new.get_pid
      end

      def create_pid(pid)
        begin
          open(pid_path, 'w') do |f|
            f.puts pid
          end
        rescue => e
          STDERR.puts "Error: Unable to open #{pid_path} for writing:\n\t" +
              "(#{e.class}) #{e.message}"
          exit!
        end
      end

      def get_pid
        pid = false
        begin
          open(pid_path, 'r') do |f|
            pid = f.readline
            pid = pid.to_s.gsub(/[^0-9]/,'')
          end
        rescue => e
          STDERR.puts "Error: Unable to open #{pid_path} for reading:\n\t" +
              "(#{e.class}) #{e.message}"
          exit
        end

        pid.to_i
      end

      def remove_pidfile
        begin
          File.unlink(pid_path)
        rescue => e
          STDERR.puts "ERROR: Unable to unlink #{path}:\n\t" +
            "(#{e.class}) #{e.message}"
          exit
        end
      end

      def process_exists?
        begin
          pid = get_pid
          return false unless pid
          Process.kill(0, pid)
          true
        rescue Errno::ESRCH, TypeError
          STDERR.puts "PID #{pid} is NOT running or is zombied!";
          false
        rescue Errno::EPERM
          STDERR.puts "No permission to query #{pid}!";
        rescue => e
          STDERR.puts "(#{e.class}) #{e.message}:\n\t" +
            "Unable to determine status for #{pid}."
          false
        end
      end

      def stop
        begin
          pid = get_pid
          STDERR.puts "pid : #{pid}"
          while true do
            Process.kill("TERM", pid)
            Process.wait(pid)
            sleep(2.0)
            Process.kill("KILL", pid)
            sleep(0.1)
          end
          puts "here"
        rescue Errno::ESRCH, Errno::ECHILD # no more process to kill
          remove_pidfile
          STDOUT.puts 'Stopped the process'
        rescue => e
          STDERR.puts "unable to terminate process: (#{e.class}) #{e.message}"
        end
      end

      def restart
        if process_exists?
          STDERR.puts "The process is already running. Restarting the process"
          stop
        end
        start
      end

      def start
        Dir::chdir(WORK_PATH)
        file_actions = Spoon::FileActions.new
        file_actions.close(1)
        file_actions.open(1, out_path, File::WRONLY | File::TRUNC | File::CREAT, 0600)
        file_actions.close(2)
        file_actions.open(2, out_path, File::WRONLY | File::TRUNC | File::CREAT, 0600)
        spawn_attr =  Spoon::SpawnAttributes.new
        pid = Spoon.posix_spawn EXEC, file_actions, spawn_attr, @args
        create_pid(pid)
      end

      def pid_path
        File.join(PID_PATH, "rsense.pid")
      end

      def out_path
        File.join(OUT_PATH, "rsense.log")
      end

      def ensure_paths_exist(*paths)
        paths.each do |path|
          FileUtils.mkdir_p(path) unless File.directory?(path)
        end
      end
    end
  end
end
