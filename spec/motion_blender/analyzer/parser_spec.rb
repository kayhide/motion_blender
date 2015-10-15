require 'spec_helper'
require 'motion_blender/analyzer/parser'

describe MotionBlender::Analyzer::Parser do
  use_lib_dir

  describe '#parse' do
    it 'captures requires' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      parser = MotionBlender::Analyzer::Parser.new(src)

      parser.parse
      expect(parser.requires.map(&:arg)).to eq %w(foo)
    end

    it 'captures relative requires' do
      src = fixtures_dir.join('relative_loader.rb').to_s
      parser = MotionBlender::Analyzer::Parser.new(src)

      parser.parse
      expect(parser.requires.map(&:arg)).to eq %w(lib/foo)
    end

    it 'captures requires in loop' do
      src = fixtures_dir.join('all_loader.rb').to_s
      parser = MotionBlender::Analyzer::Parser.new(src)

      parser.parse
      expect(parser.requires.map(&:arg))
        .to eq fixtures_dir.join('lib').children.map(&:to_s)
    end

    it 'skips requires in MotionBlender.raketime' do
      src = fixtures_dir.join('raketime_loader.rb').to_s
      parser = MotionBlender::Analyzer::Parser.new(src)

      parser.parse
      expect(parser.requires).to eq []
    end
  end
end
