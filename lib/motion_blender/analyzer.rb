require 'set'
require 'pathname'
require 'motion_blender/analyzer/parser'

module MotionBlender
  class Analyzer
    attr_reader :files, :dependencies
    attr_accessor :exclude_files

    def initialize
      @analyzed_files = Set.new
      @files = []
      @dependencies = {}
      @exclude_files = []
    end

    def analyze file
      return if @exclude_files.include? file
      return if @analyzed_files.include? file
      @analyzed_files << file

      parser = Parser.new file
      parser.parse
      parser.requires.reject! do |req|
        @exclude_files.include? req.file
      end

      if parser.requires.any?
        @dependencies[file] = parser.requires.map(&:file)
        @files = (@files + [file] + @dependencies[file]).uniq
        @dependencies[file].each do |f|
          analyze f
        end
      end
    end
  end
end
