require 'set'
require 'pathname'
require 'motion_blender/analyzer/parser'

module MotionBlender
  class Analyzer
    attr_reader :files, :dependencies

    def initialize
      @analyzed_files = Set.new
      @files = []
      @dependencies = {}
    end

    def analyze file, backtrace = []
      return if MotionBlender.config.excepted_files.include? file
      return if @analyzed_files.include? file
      @analyzed_files << file

      requires = parse file, backtrace
      if requires.any?
        @dependencies[file] = requires.map(&:file)
        @files = [*@files, file, *@dependencies[file]].uniq
        requires.each do |req|
          req.run_callbacks :require do
            analyze req.file, [req.trace, *backtrace]
          end
        end
      end
    end

    def parse file, backtrace
      parser = Parser.new file
      begin
        parser.run_callbacks :parse do
          parser.parse
        end
      rescue LoadError => err
        err.set_backtrace [parser.last_trace, *backtrace].compact
        raise err
      end
      parser.requires
    end
  end
end
