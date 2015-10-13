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

    def analyze file, backtrace = []
      return if @exclude_files.include? file
      return if @analyzed_files.include? file
      @analyzed_files << file

      parser = Parser.new file
      begin
        parser.parse
      rescue LoadError => err
        err.set_backtrace [parser.last_trace, *backtrace].compact
        raise err
      end

      requires = parser.requires.reject { |req| exclude? req }
      if requires.any?
        @dependencies[file] = requires.map(&:file)
        @files = [*@files, file, *@dependencies[file]].uniq
        requires.each do |req|
          analyze req.file, [req.trace, *backtrace]
        end
      end
    end

    private

    def exclude? require
      (@exclude_files & [require.file, require.arg]).any?
    end
  end
end
