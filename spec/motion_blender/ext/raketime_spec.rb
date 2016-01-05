require 'spec_helper'
require 'motion_blender/ext/raketime'

module MotionBlender
  describe Ext::Raketime do
    before do
      @ext = double(config: Config.new)
      @ext.extend Ext::Raketime
    end

    describe '#incept' do
      it 'adds file to config.incepted_files' do
        expect {
          @ext.incept 'incepted'
        }.to change { @ext.config.incepted_files }.to %w(incepted)
      end

      describe 'without arg' do
        it 'adds caller file' do
          allow(@ext).to receive(:caller) {
            ["/path/to/incepted.rb:1:in `dummy'"]
          }
          expect {
            @ext.incept
          }.to change {
            @ext.config.incepted_files
          }.to %w(/path/to/incepted.rb)
        end
      end
    end

    describe '#except' do
      it 'adds file to config.excepted_files' do
        expect {
          @ext.except 'excepted'
        }.to change { @ext.config.excepted_files }.to %w(excepted)
      end

      describe 'without arg' do
        it 'adds caller file' do
          allow(@ext).to receive(:caller) {
            ["/path/to/excepted.rb:1:in `dummy'"]
          }
          expect {
            @ext.except
          }.to change {
            @ext.config.excepted_files
          }.to %w(/path/to/excepted.rb)
        end
      end
    end

    describe '#use_motion_dir' do
      use_lib_dir

      before do
        allow(@ext).to receive(:motion?) { true }
      end

      it 'unshifts dir into $LOAD_PATH' do
        dir = fixtures_dir.join('motion').to_s
        expect {
          @ext.use_motion_dir dir
        }.to change(@ext.config, :motion_dirs).to eq [dir]
      end

      describe 'without arg' do
        it 'detects motion dir automatically from caller path' do
          dir = fixtures_dir.join('motion').to_s
          allow(@ext).to receive(:caller) {
            [fixtures_dir.join('lib/foo.rb').to_s + ":1:in `dummy'"]
          }
          expect {
            @ext.use_motion_dir
          }.to change(@ext.config, :motion_dirs).to eq [dir]
        end

        it 'detects motion dir automatically ascending from caller path' do
          dir = fixtures_dir.join('motion').to_s
          allow(@ext).to receive(:caller) {
            [fixtures_dir.join('lib/foo/bar/fiz/baz.rb').to_s + ":1:in `dummy'"]
          }
          expect {
            @ext.use_motion_dir
          }.to change(@ext.config, :motion_dirs).to eq [dir]
        end
      end
    end

    describe '#motion?' do
      it 'returns true if Motion::Project is defined' do
        stub_const 'Motion::Project', Class.new
        expect(@ext.motion?).to eq true
      end

      it 'returns false if Motion::Project is not defined' do
        expect(@ext.motion?).to eq false
      end
    end

    describe '#raketime?' do
      it 'returns true' do
        expect(@ext.raketime?).to eq true
      end
    end

    describe '#runtime?' do
      it 'returns false' do
        expect(@ext.runtime?).to eq false
      end
    end

    describe '#raketime' do
      it 'runs block if motion? is true' do
        allow(@ext).to receive(:motion?) { true }
        expect { |b|
          @ext.raketime(&b)
        }.to yield_control
      end

      it 'skips block if motion? is false' do
        allow(@ext).to receive(:motion?) { false }
        expect { |b|
          @ext.raketime(&b)
        }.not_to yield_control
      end
    end

    describe '#runtime' do
      it 'skips block' do
        expect { |b|
          @ext.raketime(&b)
        }.not_to yield_control
      end
    end
  end
end
