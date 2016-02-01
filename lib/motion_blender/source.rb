require 'parser/current'
require 'motion_blender/flag_attribute'

module MotionBlender
  class Source
    def self.parse code, attrs = {}
      attrs[:ast] = ::Parser::CurrentRuby.parse(code)
      new(attrs)
    end

    def self.parse_file file
      ast = ::Parser::CurrentRuby.parse_file(file)
      new(ast: ast)
    end

    include FlagAttribute

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
        if @ast
          @ast.children.grep(::Parser::AST::Node).map do |ast|
            Source.new(ast: ast, parent: self)
          end
        else
          []
        end
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

    def global_constants
      @global_constants ||=
        if root?
          Array.wrap(find_global_constants).flatten.compact.uniq
        else
          root.global_constants
        end
    end

    def find_global_constants
      if type.module? || type.class?
        if children.first.type.const?
          children.first.code.split('::', 2).first
        end
      else
        children.map(&:find_global_constants)
      end
    end

    def wrapping_modules
      @wrapping_modules ||=
        [*parent.try(:wrapping_modules), parent.try(:this_module)].compact
    end

    def this_module
      if (type.module? || type.class?) && children.first.type.const?
        [type.to_s, children.first.code]
      end
    end
  end
end
