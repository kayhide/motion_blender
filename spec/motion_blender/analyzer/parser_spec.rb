require 'spec_helper'
require 'motion_blender/analyzer/parser'

describe MotionBlender::Analyzer::Parser do
  before do
    $:.unshift fixtures_dir.join('lib')
  end

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

    it 'fails when require arg is invalid' do
      src = fixtures_dir.join('invalid_loader.rb').to_s
      parser = MotionBlender::Analyzer::Parser.new(src)

      expect {
        parser.parse
      }.to raise_error { |error|
        expect(error).to be_a LoadError
        expect(error.message).to include 'require invalid'
      }
    end

    it 'fails when required file is missing' do
      src = fixtures_dir.join('missing_loader.rb').to_s
      parser = MotionBlender::Analyzer::Parser.new(src)

      expect {
        parser.parse
      }.to raise_error { |error|
        expect(error).to be_a LoadError
        expect(error.message).to include 'missing_feature'
      }
    end
  end

  describe '#resolve_path' do
    it 'returns file path' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      parser = MotionBlender::Analyzer::Parser.new(src)

      foo = fixtures_dir.join('lib/foo.rb').to_s
      expect(parser.resolve_path(:require, 'foo')).to eq foo
    end
  end
end
