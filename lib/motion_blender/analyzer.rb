require 'pathname'
require 'motion_blender/analyzer/hooker'

module MotionBlender
  class Analyzer
    attr_reader :files, :requires, :dependencies

    def analyze file
      Hooker.clear
      with_hook do
        load file
      end
      @requires = (@requires || {}).merge(Hooker.requires)
      if @requires[file]
        @files.unshift file
      end
    rescue NameError
      raise if Hooker.requires.any?
    end

    def with_hook
      orig = $LOADED_FEATURES.dup
      $LOADED_FEATURES.clear
      Hooker.activate
      yield
      Hooker.deactivate
      @files = (@files || []) | $LOADED_FEATURES.dup
      $LOADED_FEATURES.concat(orig - $LOADED_FEATURES)
    end

    def create_dependencies
      @dependencies ||= {}
      requires.each do |file, features|
        @dependencies[file] ||= features.map { |feature| resolve_path feature }
      end
    end

    def resolve_path feature
      (candidates_for(feature).to_a & files).first
    end

    def candidates_for feature
      path = Pathname.new(feature)
      dirs = path.relative? ? $: : ''
      exts = path.extname.empty? ? ['', '.rb'] : ['']
      Enumerator.new do |y|
        dirs.product(exts).each do |dir, ext|
          y << (Pathname.new(dir) + path).cleanpath.to_path + ext
        end
      end
    end
  end
end
