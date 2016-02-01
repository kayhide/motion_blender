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
      obj = evaluating_object
      with_refinements do
        obj.instance_eval(source.code, source.file, source.line)
        requires
      end
    end

    private

    delegate :refinements, to: :class

    def evaluating_object
      obj = Object.new
      constants = @source.global_constants.select do |c|
        Object.const_defined? c.to_sym
      end
      constants.each { |c| obj.instance_eval "#{c} = ::#{c}" }
      if @source.wrapping_modules.present?
        ms = @source.wrapping_modules.map { |p| p.join(' ') }
        s = [*ms, 'self', *Array.new(ms.length, 'end')].join(';')
        obj = obj.instance_eval s
      end
      obj
    end

    def with_refinements
      apply_refinements
      yield
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
