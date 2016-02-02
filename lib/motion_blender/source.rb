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

    def attributes
      {
        'code' => @code,
        'file' => @file,
        'line' => @line,
        'type' => @type.to_s,
        'method' => @method.try(:to_s)
      }
    end
  end
end
