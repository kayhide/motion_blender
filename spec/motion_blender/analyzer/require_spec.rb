require 'spec_helper'
require 'motion_blender/analyzer/require'

describe MotionBlender::Analyzer::Require do
  describe '#match?' do
    subject {
      described_class.new('path/to/loader.rb', :require, 'feature').tap do |req|
        req.file = 'path/to/feature.rb'
      end
    }

    it 'returns true if file is matched' do
      expect(subject.match?('path/to/feature.rb')).to eq true
    end

    it 'returns true if arg is matched' do
      expect(subject.match?('feature')).to eq true
    end

    it 'returns false if file nor arg is not matched' do
      expect(subject.match?('mismatch')).to eq false
    end
  end
end
