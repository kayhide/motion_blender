require 'spec_helper'
require 'motion_blender/analyzer/parser'

describe MotionBlender::Analyzer::Parser do
  Cache = MotionBlender::Analyzer::Cache

  use_lib_dir

  describe '#parse' do
    it 'captures requires' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      parser = described_class.new(src)

      parser.parse
      expect(parser.requires.map(&:arg)).to eq %w(foo)
    end

    it 'captures relative requires' do
      src = fixtures_dir.join('relative_loader.rb').to_s
      parser = described_class.new(src)

      parser.parse
      expect(parser.requires.map(&:arg)).to eq %w(lib/foo)
    end

    it 'captures requires in loop' do
      src = fixtures_dir.join('all_loader.rb').to_s
      parser = described_class.new(src)

      parser.parse
      expect(parser.requires.map(&:arg))
        .to eq fixtures_dir.join('lib').children.map(&:to_s)
    end

    it 'evals rescue clause' do
      src = fixtures_dir.join('rescue_loader.rb').to_s
      parser = described_class.new(src)

      parser.parse
      expect(parser.requires).to eq []
    end

    it 'skips requires in MotionBlender.raketime' do
      src = fixtures_dir.join('raketime_loader.rb').to_s
      parser = described_class.new(src)

      parser.parse
      expect(parser.requires).to eq []
    end

    describe 'with cache enabled' do
      use_cache_dir

      it 'caches' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        parser = described_class.new(src)
        expect {
          parser.parse
        }.to change { parser.cache.cache_file.exist? }.to(true)
      end

      it 'loads cache' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        parser = described_class.new(src)
        parser.parse

        parser = described_class.new(src)
        expect(parser).not_to receive(:traverse)
        parser.parse
        expect(parser.requires.map(&:arg)).to eq %w(foo)
      end
    end
  end
end
