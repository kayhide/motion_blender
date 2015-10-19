require 'spec_helper'
require Bundler.root.join('motion/motion_blender/ext/runtime')

describe MotionBlender::Ext::Runtime do
  before do
    @ext.extend MotionBlender::Ext::Runtime
  end

  describe '#incept' do
    it 'skips' do
      @ext.incept
    end
  end

  describe '#except' do
    it 'skips' do
      @ext.except
    end
  end

  describe '#use_motion_dir' do
    it 'skips' do
      @ext.use_motion_dir
    end
  end

  describe '#motion?' do
    it 'returns true' do
      expect(@ext.motion?).to eq true
    end
  end

  describe '#raketime?' do
    it 'returns false' do
      expect(@ext.raketime?).to eq false
    end
  end

  describe '#runtime?' do
    it 'returns true' do
      expect(@ext.runtime?).to eq true
    end
  end

  describe '#raketime' do
    it 'skips block' do
      expect { |b|
        @ext.raketime(&b)
      }.not_to yield_control
    end
  end

  describe '#runtime' do
    it 'runs block' do
      expect { |b|
        @ext.runtime(&b)
      }.to yield_control
    end
  end
end
