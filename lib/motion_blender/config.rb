module MotionBlender
  class Config
    attr_reader :incepted_files, :excepted_files, :motion_dirs

    def initialize
      @incepted_files = []
      @excepted_files = []
      @motion_dirs = []
    end
  end

  module_function

  def config
    @config ||= Config.new
  end
end
