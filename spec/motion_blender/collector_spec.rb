require 'spec_helper'

describe MotionBlender::Collector do
  Interpreters = MotionBlender::Interpreters

  describe '.interpreters' do
    it 'returns interpreters indexed by method' do
      expected = {
        require: Interpreters::RequireInterpreter,
        require_relative: Interpreters::RequireRelativeInterpreter,
        __ORIGINAL__: Interpreters::OriginalInterpreter
      }
      expect(described_class.interpreters).to include expected
    end
  end

  describe '.get' do
    let(:source) { double }

    it 'returns new collector' do
      expect(described_class.get(source)).to be_a described_class
    end

    it 'calls .prepare and set .prepared?' do
      described_class.reset_prepared
      expect(described_class).to receive(:prepare).and_call_original
      expect {
        described_class.get(source)
      }.to change(described_class, :prepared?).to(true)
    end
  end

  describe '.requirable_methods' do
    it 'returns methods' do
      expect(described_class.requirable_methods)
        .to match_array [:require, :require_relative]
    end
  end
end
