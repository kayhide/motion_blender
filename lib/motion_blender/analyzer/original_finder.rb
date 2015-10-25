module MotionBlender
  class Analyzer
    class OriginalFinder
      attr_reader :file, :original

      def initialize file
        @file = file
      end

      def find
        dir = MotionBlender.config.motion_dirs.find { |d| @file.start_with? d }
        fail 'not found in motion_dirs' unless dir
        arg = Pathname.new(@file).relative_path_from(Pathname.new(dir))
        @original = candidates_for(arg).find(&:file?).try(&:to_s)
      end

      def candidates_for arg
        Enumerator.new do |y|
          $LOAD_PATH.each do |dir|
            y << Pathname.new(dir).join(arg)
          end
        end
      end
    end
  end
end
