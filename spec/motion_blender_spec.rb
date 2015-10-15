require 'spec_helper'

describe MotionBlender do
  it 'has a version number' do
    expect(MotionBlender::VERSION).not_to be nil
  end

  describe '.use_motion_dir' do
    before do
      allow(MotionBlender).to receive(:motion?) { true }
    end

    it 'unshifts dir into $LOAD_PATH' do
      dir = fixtures_dir.join('motion').to_s
      expect($LOAD_PATH).to receive(:unshift).with(dir)
      MotionBlender.use_motion_dir dir
    end

    describe 'without arg' do
      use_lib_dir

      it 'detects motion dir automatically from caller path' do
        dir = fixtures_dir.join('motion').to_s
        expect($LOAD_PATH).to receive(:unshift).with(dir)
        allow(MotionBlender).to receive(:caller) {
          [fixtures_dir.join('lib/foo.rb').to_s + ":1:in `dummy'"]
        }
        MotionBlender.use_motion_dir
      end

      it 'detects motion dir automatically ascending from caller path' do
        dir = fixtures_dir.join('motion').to_s
        expect($LOAD_PATH).to receive(:unshift).with(dir)
        allow(MotionBlender).to receive(:caller) {
          [fixtures_dir.join('lib/foo/bar/fiz/baz.rb').to_s + ":1:in `dummy'"]
        }
        MotionBlender.use_motion_dir
      end
    end
  end
end
