require 'set'
require 'pathname'
require 'motion_blender/interpreters'
require 'motion_blender/analyzer/parser'

module MotionBlender
  class Analyzer
    attr_reader :files, :dependencies

    def initialize
      @analyzed_files = Set.new
      @files = []
      @dependencies = {}
      @autoloads = {}
      @file_stack = []
    end

    def analyze file, backtrace = []
      @file_stack.push file

      return if MotionBlender.config.excepted_files.include? file
      return if @analyzed_files.include? file
      @analyzed_files << file

      parser = parse file, backtrace
      requires = merge parser
      requires.each do |req|
        req.run_callbacks :require do
          analyze req.file, [req.trace, *backtrace]
        end
      end
    ensure
      @file_stack.pop
    end

    def pick_autoloads parser
      parser.requires.select(&:autoload?).each do |req|
        @autoloads[req.autoload_const_name] ||= []
        @autoloads[req.autoload_const_name] << req
      end
    end

    def merge parser
      pick_autoloads parser

      reqs = parser.dependent_requires(autoloads: @autoloads)
      reqs = reqs.reject { |req| @file_stack.include? req.file }
      if reqs.present?
        files = reqs.map(&:file)
        @dependencies[parser.file] = files
        @files = [*@files, parser.file, *files].uniq
        reqs
      else
        []
      end
    end

    def parse file, backtrace
      parser = Parser.new file
      begin
        parser.parse
      rescue LoadError => err
        err.set_backtrace [parser.last_trace, *backtrace].compact
        raise err
      end
      parser
    end
  end
end
