require 'spec_helper'

describe MotionBlender::Interpreters::OriginalInterpreter do
  use_lib_dir
  use_collector

  let(:src_file) { fixtures_dir.join('motion/original.rb').to_s }

  subject { described_class.new(collector) }

  describe '#interpret' do
    it 'returns file path with lib dir' do
      motion_dir = fixtures_dir.join('motion').to_s
      MotionBlender.config.motion_dirs << motion_dir

      original = fixtures_dir.join('lib/original.rb').to_s
      expect(subject.interpret).to eq original
    end
  end
end
