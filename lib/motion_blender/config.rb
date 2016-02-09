require 'set'

module MotionBlender
  class Config
    attr_reader :incepted_files, :excepted_files, :motion_dirs
    attr_reader :builtin_features
    attr_accessor :cache_dir

    def initialize
      @incepted_files = []
      @excepted_files = Set.new
      @motion_dirs = []
      @builtin_features = Set.new %w(bigdecimal rational date)
      @cache_dir = Pathname.new('build/analyze')
    end
  end

  module_function

  def config
    @config ||= Config.new
  end

  def reset_config
    @config = nil
  end
end
