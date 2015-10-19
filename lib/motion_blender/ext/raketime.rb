require 'motion_blender/config'

module MotionBlender
  module Ext
    module Raketime
      def incept file = nil
        file ||= caller.first.split(':', 2).first
        config.incepted_files << file
      end

      def except file = nil
        file ||= caller.first.split(':', 2).first
        config.excepted_files << file
      end

      def use_motion_dir dir = nil
        return unless motion?

        unless dir
          file = caller.first.split(':', 2).first
          Pathname.new(file).dirname.ascend do |path|
            if $LOAD_PATH.include?(path.to_s)
              dir = path.dirname.join('motion').to_s
              break
            end
          end
        end
        unless config.motion_dirs.include? dir
          config.motion_dirs << dir
        end
      end

      def motion?
        !!(defined?(Motion) && defined?(Motion::Project))
      end

      def raketime?
        true
      end

      def runtime?
        false
      end

      def raketime
        yield if motion?
      end

      def runtime
      end
    end
  end

  extend Ext::Raketime
end
