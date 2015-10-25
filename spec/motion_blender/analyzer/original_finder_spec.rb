require 'spec_helper'

describe MotionBlender::Analyzer::OriginalFinder do
  use_lib_dir

  describe '#find' do
    it 'returns file path with lib dir' do
      motion_dir = fixtures_dir.join('motion').to_s
      MotionBlender.config.motion_dirs << motion_dir
      src = fixtures_dir.join('motion/original.rb').to_s
      req = MotionBlender::Analyzer::OriginalFinder.new(src)

      original = fixtures_dir.join('lib/original.rb').to_s
      expect(req.find).to eq original
    end
  end
end
