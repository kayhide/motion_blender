require 'set'
require 'pathname'
require 'motion_blender/analyzer/parser'

module MotionBlender
  class Analyzer
    attr_reader :files, :dependencies
    attr_accessor :exclude_files

    def initialize
      @analyzed_files = Set.new
      @exclude_files = Set.new
      @files = []
      @dependencies = {}
    end

    def analyze file, backtrace = [], &proc
      return if @exclude_files.include? file
      return if @analyzed_files.include? file
      @analyzed_files << file
      proc.call file if proc

      parser = Parser.new file
      parser.exclude_files = @exclude_files
      begin
        parser.parse
      rescue LoadError => err
        err.set_backtrace [parser.last_trace, *backtrace].compact
        raise err
      end

      requires = parser.requires
      if requires.any?
        @dependencies[file] = requires.map(&:file)
        @files = [*@files, file, *@dependencies[file]].uniq
        requires.each do |req|
          analyze req.file, [req.trace, *backtrace], &proc
        end
      end
    end
  end
end
