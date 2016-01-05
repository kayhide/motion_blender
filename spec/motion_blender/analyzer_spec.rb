require 'spec_helper'

module MotionBlender
  describe Analyzer do
    use_lib_dir

    describe '#analyze' do
      it 'captures requires' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        subject.analyze src
        foo = fixtures_dir.join('lib/foo.rb').to_s
        bar = fixtures_dir.join('lib/bar.rb').to_s

        expect(subject.dependencies[src]).to eq [foo]
        expect(subject.dependencies[foo]).to eq [bar]
        expect(subject.dependencies[bar]).to eq nil
      end

      it 'works with circular require' do
        src = fixtures_dir.join('circular_loader.rb').to_s
        subject.analyze src
        circular = fixtures_dir.join('lib/circular.rb').to_s

        expect(subject.dependencies[src]).to eq [circular]
        expect(subject.dependencies[circular]).to eq [circular]
      end

      it 'works with original' do
        motion_dir = fixtures_dir.join('motion').to_s
        MotionBlender.config.motion_dirs << motion_dir

        src = fixtures_dir.join('original_loader.rb').to_s
        subject.analyze src
        cover = fixtures_dir.join('motion/original.rb').to_s
        original = fixtures_dir.join('lib/original.rb').to_s

        expect(subject.dependencies[src]).to eq [cover]
        expect(subject.dependencies[cover]).to eq [original]
      end

      it 'raises error of undefined local error' do
        src = fixtures_dir.join('invalid_loader.rb').to_s
        expect {
          subject.analyze src
        }.to raise_error { |error|
          expect(error.message).to match(/undefined local .*`invalid'/)
          expect(error.backtrace[0]).to include 'invalid_loader'
        }
      end

      it 'raises error of not found error' do
        loaders = (0..2).map { |i|
          fixtures_dir.join("error_loader_#{i}.rb").to_s
        }

        expect {
          subject.analyze loaders.last
        }.to raise_error { |error|
          expect(error.message).to match(/not found .*`raise_error'/)
          expect(error.backtrace[0]).to include "#{loaders[0]}:1"
          expect(error.backtrace[1]).to include "#{loaders[1]}:1"
          expect(error.backtrace[2]).to include "#{loaders[2]}:1"
        }
      end
    end

    describe '#files' do
      it 'returns parsing file and all required files' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        subject.analyze src
        foo = fixtures_dir.join('lib/foo.rb').to_s
        bar = fixtures_dir.join('lib/bar.rb').to_s

        expect(subject.files).to match_array [src, foo, bar]
      end

      it 'skips file with no require' do
        src = fixtures_dir.join('nil_loader.rb').to_s
        subject.analyze src

        expect(subject.files).to eq []
      end

      it 'preserves relative path' do
        dir = './spec/fixtures'
        src = File.join(dir, 'relative_loader.rb')
        subject.analyze src
        foo = File.join(dir, 'lib/foo.rb')
        bar = fixtures_dir.join('lib/bar.rb').to_s

        expect(subject.files).to eq [src, foo, bar]
      end

      it 'excludes analyzing files in excepted_files' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        MotionBlender.config.excepted_files << src
        subject.analyze src

        expect(subject.files).to match_array []
      end

      it 'excludes required files in excepted_files' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        foo = fixtures_dir.join('lib/foo.rb').to_s
        bar = fixtures_dir.join('lib/bar.rb').to_s
        MotionBlender.config.excepted_files << bar
        subject.analyze src

        expect(subject.files).to match_array [src, foo]
      end

      it 'excludes required args in excepted_files' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        foo = fixtures_dir.join('lib/foo.rb').to_s
        MotionBlender.config.excepted_files << 'bar'
        subject.analyze src

        expect(subject.files).to match_array [src, foo]
      end

      it 'excludes required args in builtin_features' do
        src = fixtures_dir.join('foo_loader.rb').to_s
        foo = fixtures_dir.join('lib/foo.rb').to_s
        MotionBlender.config.builtin_features << 'bar'
        subject.analyze src

        expect(subject.files).to match_array [src, foo]
      end
    end
  end
end
