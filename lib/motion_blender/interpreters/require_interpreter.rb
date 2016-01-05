require 'motion_blender/interpreters/base'
require 'motion_blender/interpreters/requirable'

module MotionBlender
  module Interpreters
    class RequireInterpreter < Base
      include Requirable
      interprets :require

      def candidates arg
        path = Pathname.new(arg)
        dirs = path.relative? && load_path || ['']
        exts = path.extname.empty? ? ['', '.rb'] : ['']
        Enumerator.new do |y|
          dirs.product(exts).each do |dir, ext|
            y << Pathname.new(dir).join("#{path}#{ext}")
          end
        end
      end

      private

      def load_path
        MotionBlender.config.motion_dirs + $LOAD_PATH
      end
    end
  end
end
