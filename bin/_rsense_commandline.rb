#!/usr/bin/env ruby

require 'optparse'
require 'json'
require "faraday"
require "uri"
require "timeout"

module Rsense
  class Request
    SOCKET_PATH = 'localhost'
    DEFAULT_PORT = 47367

    def self.req(jsondata)
      conn = Faraday.new(uri)

      conn.post do |req|
        req.headers["Content-Type"] = 'application.json'
        req.body = jsondata
      end
    end

    def self.uri
      uri = URI::HTTP.build({host: SOCKET_PATH, port: DEFAULT_PORT})
    end
  end

  class Main
    def self.run(jsondata)
      begin
        Timeout::timeout(1) do
          res_body = request(jsondata).body
          completions_hash = JSON.parse(res_body)
          self.stringify(completions_hash)
        end
      rescue Timeout::Error => e
        [""]
      end
    end

    def self.stringify(completions_hash)
      compls = completions_hash["completions"].map do |c|
        "#{c["name"]} #{c["qualified_name"]} #{c["base_name"]} #{c["kind"]}"
      end
      compls.join("\n")
    end

    def self.request(jsondata)
      Rsense::Request.req(jsondata)
    end
  end
end

options = { command: "code_completion" }
OptionParser.new do |opts|
  opts.banner = "Usage: rsense start [options]"

  opts.on("--project PROJECT", "project path") do |project|
    options[:project] = project
  end

  opts.on("--filepath FILEPATH", "Filepath") do |filepath|
    options[:file] = filepath
  end

  opts.on("--text TEXT", "Text") do |text|
    options[:code] = text
  end

  opts.on("--location LOCATION", "Location") do |location|
    loc = location.split(':')
    row = loc.first
    col = loc.last
    options[:location] = { row: (row.to_i + 1), column: (col.to_i + 1) }
  end
end.parse!

begin

  jsondata = JSON.generate(options)

  compls = Rsense::Main.run(jsondata)
  puts compls

rescue Exception => e
  puts "ERROR: #{e}"
end
