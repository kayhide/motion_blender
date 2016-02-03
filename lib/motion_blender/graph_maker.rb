require 'graphviz'
require 'colorable'
require 'zlib'

module MotionBlender
  class GraphMaker
    attr_reader :dependencies
    attr_accessor :title, :filter, :layout, :output

    def initialize dependencies, opts = {}
      @dependencies = dependencies
      @title = opts[:title]
      @filter = opts[:filter]
      @layout = opts[:layout].try(:to_sym) || :sfdp
      @output = opts[:output] || 'graph.pdf'
    end

    def build
      g = GraphViz.new(@title || 'Graph', type: :digraph, use: @layout)
      label = [@title, (@filter && "/#{@filter}/")].compact.join(' ')
      g[:label] = label if label.present?
      g[:overlap] = false

      deps =
        @dependencies
        .select { |k, _| acceptable? k }
        .map { |k, v| [k, v.select { |f| acceptable? f }] }
      deps.map { |k, v| [k, *v] }.flatten.uniq.reverse_each do |f|
        g.add_node f, node_options_for(f)
      end
      deps.each do |k, v|
        v.each { |f| g.add_edge k, f, edge_options_for(k, f) }
      end

      g.output(output_format => @output)
    end

    private

    def output_format
      File.extname(@output)[1..-1].to_sym
    end

    def acceptable? file
      shorten(file) =~ filter_pattern
    end

    def filter_pattern
      @filter_pattern ||= /#{@filter}/
    end

    def shorten_pattern
      @shorten_pattern ||=
        begin
          paths = MotionBlender.config.motion_dirs + $LOAD_PATH
          patterns = paths.map { |p| Regexp.escape File.join(p, '') }
          Regexp.new(patterns.join('|'))
        end
    end

    def shorten file
      file.sub(shorten_pattern, '')
    end

    def shortened file
      file[shorten_pattern]
    end

    def color_for file
      h = Zlib.crc32(shortened(file)) % 360
      Colorable::Color.new(Colorable::HSB.new(h, 90, 100))
    end

    def node_options_for file
      {
        label: shorten(file).pathmap('%X'),
        href: file,
        color: color_for(file).hex,
        fillcolor: color_for(file).hex + '99',
        style: :filled
      }
    end

    def edge_options_for file, _
      {
        color: (color_for(file) * 'Gray'.to_color).hex + '66'
      }
    end
  end
end
