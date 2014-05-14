require "pathname"
require "set"

module Rsense
  module Server
    class Options < Hash
      attr_accessor :load_path, :gem_path, :rest, :defaultFormat, :defaultEncoding

      def initialize(*args)
        @rest = []
        super(args)
      end

      def addOption(name, value=[])
        if value.class == Array
          if has_key?(name)
            value.each { |v| fetch(name).push(v) }
          else
            store(name, value)
          end
        else
          if has_key?(name)
            fetch(name).push(value)
          else
            store(name, [value])
          end
        end
      end

      def addOptions(name, value=[])
        if list = fetch(name, nil)
          if value.class == Array
            value.each { |v| list.push(v) }
          else
            list.push(value)
          end
        else
          if value.class == Array
            store(name, value)
          else
            store(name, [value])
          end
        end
      end

      def hasOption(name)
        has_key?(name)
      end

      def getOption(name)
        list = fetch(name, nil)
        list[0] if list
      end

      def getOptions(name)
        fetch(name, nil)
      end

      def addRestArg(arg)
        @rest.push(arg)
      end

      def getRestArgs
        @rest
      end

      def isFormatGiven
        hasOption("format")
      end

      def isEncodingGiven
        hasOption("encoding")
      end

      def getFormat
        fetch("format", @defaultFormat)
      end

      def isPlainFormat
        "plain".eql? getFormat()
      end

      def isEmacsFormat
        "emacs".eql? getFormat()
      end

      def getEncoding
        fetch("encoding", @defaultEncoding)
      end

      def getPrompt
        if has_key?("no-prompt")
          return ""
        else
          fetch("prompt", "")
        end
      end

      def getFile
        if has_key?("file")
          Pathname.new(fetch("file"))
        end
      end

      def isFileStdin
        has_key?("file") unless fetch("file", "").match(/-/)
      end

      def getHereDocReader(reader)
        Rsense::Util::HereDocReader.new(reader, "EOF")
      end

      def getLocation
        location = getOption("location")
        if !location
          return Rsense::Server::Location.mark_location("_|_")
        end
        lr = location.split(":")
        if lr.size == 2
          Rsense::Server::Location.logical_location(lr[0].to_i, lr[1].to_i)
        else
          Rsense::Server::Location.offset_location(lr[0])
        end
      end

      def getLine
        getOption("line").to_i
      end

      def getEndMark
        getOption("end-mark")
      end

      def isDebug
        has_key?("debug")
      end

      def getLog
        getOption("log")
      end

      def getLogLevel
        if isDebug
          Rsense::Util::Logger::Level::DEBUG
        end
        level = getOption("log-level")
        if level
          Rsense::Util::Logger::Level.valueOf(level.upcase)
        else
          Rsense::Util::Logger::Level::MESSAGE
        end
      end

      def getProgress
        if has_key?("progress")
          getOption("progress").to_i
        else
          0
        end
      end

      def getRsenseHome
        getOption("home") || "."
      end

      def getLoadPath
        @load_path = @load_path || Rsense::Server::LoadPath.paths
      end

      def getGemPath
        @gem_path = @gem_path || Rsense::Server::GemPath.paths
      end

      def getProject
        getOption("project")
      end

      def isDetectProject
        has_key?("detect-project")
      end

      def getDetectProject
        if has_key?("detect-project")
          Pathname.new(getOption("detect-project"))
        end
      end

      def isKeepEnv
        has_key?("keep-env")
      end

      def isTime
        has_key?("time")
      end

      def isTest
        has_key?("test")
      end

      def isTestColor
        has_key?("test-color")
      end

      def getTest
        getOption("test")
      end

      def getShouldContain
        getStringSet("should-contain")
      end

      def getShouldNotContain
        getStringSet("should-not-contain")
      end

      def getShouldBe
        if has_key?("should-be-empty")
          return Java::java.util.Collections.emptySet()
        else
          getStringSet("should-be")
        end
      end

      def isShouldBeGiven
        has_key?("should-be") || has_key?("should-be-empty")
      end

      def isPrintAST
        has_key?("print-ast")
      end

      def getName
        getOption("name")
      end

      def getPrefix
        getOption("prefix")
      end

      def isVerbose
        has_key?("verbose")
      end

      def inherit(parent)
        addOption("home", parent.getRsenseHome())
        if (parent.isDebug())
            addOption("debug")
        end
        addOption("log", parent.getLog())
        addOption("log-level", parent.getOption("log-level"))
        addOptions("load-path", parent.getOptions("load-path"))
        addOptions("gem-path", parent.getOptions("gem-path"))
        addOption("format", parent.getFormat())
        addOption("encoding", parent.getEncoding())
        if (parent.isTime())
            addOption("time")
        end
        if (parent.isTestColor())
            addOption("test-color")
        end
      end

      def getConfig
        getOption("config")
      end

      def loadConfig(config)
        path = Pathname.new(config).expand_path
        if path.exist?
          File.open("/replace/me") do |f|
            f.readlines.each do |line|
              lr = line.split(/\s*=\s*/)
              if lr.size >= 1
                addOption(lr[0], lr.size >= 2 ? lr[1] : nil)
              end
            end
          end
        else
          puts "Config file: #{path} does not exist"
        end
      end

      def getStringSet(name)
        result = Set.new
        str = getOption(name)
        if !str
          Java::java.util.Collections.emptySet()
        else
          result << str.split(",")
        end
      end

      def getPathList(name)
        list = getOptions(name)
        result = []
        if list
          list.each do |paths|
            paths.split(File::PATH_SEPARATOR).each do |path|
              result << path
            end
          end
        end
      end

      def defaultFormat
        "plain"
      end

      def default_format
        "plain"
      end

      def defaultEncoding
        "UTF-8"
      end

      def default_encoding
        "UTF-8"
      end

      def defaultEndMark
        "END"
      end

      def default_end_mark
        "END"
      end

      def defaultPrompt
        "> "
      end

      def default_prompt
        "> "
      end

    end
  end
end

