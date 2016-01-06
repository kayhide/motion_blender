require 'motion_blender/source'
require 'motion_blender/require'

module MotionBlender
  class Collector
    class << self
      def interpreters
        @interpreters ||= []
      end

      def register interpreter
        interpreters << interpreter
        interpreter
      end

      def requirable? source
        interpreters.each_with_object(source).any?(&:requirable?)
      end

      def acceptable? source
        !source.type.block? ||
          (source.children.first.code != 'MotionBlender.raketime')
      end

      def collect_requires source
        collector = new(source, interpreters)
        interpreters.each do |interpreter|
          get_refinement_for(interpreter.receiver).module_eval do
            define_method interpreter.method do |*args, &proc|
              collector.interpreters[interpreter.key].interpret(*args, &proc)
            end
          end
        end
        Object.new.instance_eval(source.code, source.file, source.line)
        collector.requires
      ensure
        clear_refinements
      end

      private

      def refinements
        @refinements ||= {}
      end

      def get_refinement_for klass
        refinements[klass] ||=
          begin
            Module.new do
              klass.prepend self
            end
          end
      end

      def clear_refinements
        refinements.each do |_, mod|
          mod.module_eval do
            instance_methods.each do |m|
              remove_method m
            end
          end
        end
      end
    end

    attr_accessor :source, :interpreters, :requires

    def initialize source, interpreters
      @source = source
      @interpreters = interpreters.map do |interpreter|
        [interpreter.key, interpreter.new(self)]
      end.to_h
      @requires = []
    end
  end
end
