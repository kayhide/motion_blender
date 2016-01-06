require 'spec_helper'

module MotionBlender
  describe Interpreters::OriginalInterpreter do
    use_lib_dir

    let(:file) { fixtures_dir.join('motion/original.rb').to_s }

    subject {
      described_class.new(double).tap do |interpreter|
        allow(interpreter).to receive(:file) { file }
      end
    }

    describe '#interpret' do
      it 'returns file path with lib dir' do
        motion_dir = fixtures_dir.join('motion').to_s
        MotionBlender.config.motion_dirs << motion_dir

        original = fixtures_dir.join('lib/original.rb').to_s
        expect(subject.interpret).to eq original
      end
    end
  end
end
