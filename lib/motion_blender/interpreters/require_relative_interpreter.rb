require 'motion_blender/interpreters/base'

module MotionBlender
  module Interpreters
    class RequireRelativeInterpreter < Base
      include Requirable
      interprets :require_relative

      def interpret arg
        find_require(arg) do |req|
          requires << req
        end
      end

      def candidates arg
        path = Pathname.new(file).dirname.join(arg)
        exts = path.extname.empty? ? ['', '.rb'] : ['']
        Enumerator.new do |y|
          exts.each do |ext|
            y << Pathname.new("#{path}#{ext}")
          end
        end
      end
    end
  end
end
