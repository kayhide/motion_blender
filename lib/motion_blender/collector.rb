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

      def refinements
        @refinements ||= Hash.new do |hash, key|
          hash[key] = Module.new { key.prepend self }
        end
      end
    end

    attr_accessor :source, :interpreters, :requires

    def initialize source
      @source = source
      @interpreters = self.class.interpreters.map do |interpreter|
        [interpreter.key, interpreter.new(self)]
      end.to_h
      @requires = []
    end

    def collect_requires
      constants = @source.global_constants.select do |c|
        Object.const_defined? c.to_sym
      end
      prepends = constants.map { |c| "#{c} = ::#{c}" }

      with_refinements do |obj|
        prepends.each { |s| obj.instance_eval s }
        obj.instance_eval(source.code, source.file, source.line)
        requires
      end
    end

    private

    delegate :refinements, to: :class

    def with_refinements
      apply_refinements
      yield Object.new
    ensure
      clear_refinements
    end

    def apply_refinements
      interpreters.each do |_, interpreter|
        refinements[interpreter.receiver].module_eval do
          define_method interpreter.method do |*args, &proc|
            interpreter.object = self
            interpreter.interpret(*args, &proc)
          end
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
end
