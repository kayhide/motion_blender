require 'spec_helper'
require 'motion_blender/analyzer/require'

describe MotionBlender::Analyzer::Require do
  use_lib_dir

  before do
    MotionBlender.reset_config
  end

  describe '#resolve_path' do
    it 'returns file path' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      req = MotionBlender::Analyzer::Require.new(src, :require, 'foo')

      foo = fixtures_dir.join('lib/foo.rb').to_s
      expect(req.resolve_path).to eq foo
    end

    it 'returns file path with motion dir' do
      motion_dir = fixtures_dir.join('motion').to_s
      MotionBlender.config.motion_dirs << motion_dir
      src = fixtures_dir.join('foo_loader.rb').to_s
      req = MotionBlender::Analyzer::Require.new(src, :require, 'foo')

      foo = fixtures_dir.join('motion/foo.rb').to_s
      expect(req.resolve_path).to eq foo
    end

    it 'fails when required file is missing' do
      src = fixtures_dir.join('missing_loader.rb').to_s
      arg = 'missing_feature'
      req = MotionBlender::Analyzer::Require.new(src, :require, arg)

      expect {
        req.resolve_path
      }.to raise_error { |error|
        expect(error).to be_a LoadError
        expect(error.message).to include arg
      }
    end
  end
end
