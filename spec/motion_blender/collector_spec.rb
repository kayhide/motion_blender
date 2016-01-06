require 'spec_helper'

module MotionBlender
  describe Collector do
    describe '.interpreters' do
      it 'returns all registered interpreters' do
        expected = [
          Interpreters::RequireInterpreter,
          Interpreters::RequireRelativeInterpreter,
          Interpreters::AutoloadInterpreter,
          Interpreters::ModuleAutoloadInterpreter,
          Interpreters::OriginalInterpreter
        ]
        expect(described_class.interpreters).to match_array expected
      end
    end

    describe '.requirable?' do
      it 'calls .interpreters #requirable?' do
        interpreters = [
          double(requirable?: false),
          double(requirable?: true),
          double(requirable?: true)
        ]
        allow(described_class).to receive(:interpreters) { interpreters }

        source = double
        described_class.requirable? source
        expect(interpreters[0]).to have_received(:requirable?).with(source)
        expect(interpreters[1]).to have_received(:requirable?).with(source)
        expect(interpreters[2]).not_to have_received(:requirable?)
      end
    end
  end
end
