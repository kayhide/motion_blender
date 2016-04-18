require 'parser/current'
require 'motion_blender/flag_attribute'
require 'motion_blender/source/wrapping_modules'
require 'motion_blender/source/global_constants'
require 'motion_blender/source/referring_constants'

module MotionBlender
  class Source
    include FlagAttribute
    include WrappingModules
    include GlobalConstants
    include ReferringConstants

    def self.parse code, attrs = {}
      attrs[:ast] = ::Parser::CurrentRuby.parse(code)
      new(attrs)
    end

    def self.parse_file file
      ast = ::Parser::CurrentRuby.parse_file(file)
      new(ast: ast)
    end

    attr_reader :code, :file, :line, :parent, :type, :method, :ast
    flag_attribute :evaluated

    def initialize attrs = {}
      @evaluated = false
      ast = attrs.delete :ast
      if ast
        @code = ast.loc.expression.try(:source)
        @file = ast.loc.expression.try(:source_buffer).try(:name)
        @line = ast.loc.expression.try(:line)
        @type = ast.type.to_s.inquiry
        @method = @type.send? ? ast.children[1] : nil
        @ast = ast
      end
      attrs.each do |k, v|
        instance_variable_set "@#{k}", v
      end
      @type = @type.to_s.inquiry
      @method = @method.try(:to_sym)
    end

    def to_s
      "#{file}:#{line}:in `#{method || type}'"
    end

    def children
      @children ||=
        @ast
        .try(:children).to_a
        .select { |ast| ast.nil? || ast.is_a?(::Parser::AST::Node) }
        .map { |ast| Source.new(ast: ast, parent: self) }
    end

    def child_at *args
      i = args.shift
      args.present? ? children[i].child_at(*args) : children[i]
    end

    def root?
      parent.nil?
    end

    def root
      root? ? self : parent.root
    end

    def ancestors
      root? ? [self] : [self, *parent.ancestors]
    end

    def like_module?
      type.module? || type.class?
    end

    def attributes
      {
        'code' => @code,
        'file' => @file,
        'line' => @line,
        'type' => @type.to_s,
        'method' => @method.try(:to_s),
        'global_constants' => global_constants,
        'wrapping_modules' => wrapping_modules
      }
    end
  end
end
