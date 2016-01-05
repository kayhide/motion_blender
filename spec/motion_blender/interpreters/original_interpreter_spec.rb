require 'spec_helper'

describe MotionBlender::Interpreters::OriginalInterpreter do
  use_lib_dir

  subject {
    interpretor = described_class.new(nil)
    allow(interpretor).to receive(:file) { file }
    interpretor
  }

  describe '#interpret' do
    let(:file) { fixtures_dir.join('motion/original.rb').to_s }

    it 'returns file path with lib dir' do
      motion_dir = fixtures_dir.join('motion').to_s
      MotionBlender.config.motion_dirs << motion_dir

      original = fixtures_dir.join('lib/original.rb').to_s
      expect(subject.interpret).to eq original
    end
  end
end
