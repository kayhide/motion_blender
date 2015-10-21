require 'spec_helper'

describe MotionBlender::Analyzer do
  use_lib_dir

  before do
    @analyzer = MotionBlender::Analyzer.new
  end

  describe '#analyze' do
    it 'captures requires' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      @analyzer.analyze src
      foo = fixtures_dir.join('lib/foo.rb').to_s
      bar = fixtures_dir.join('lib/bar.rb').to_s

      expect(@analyzer.dependencies[src]).to eq [foo]
      expect(@analyzer.dependencies[foo]).to eq [bar]
      expect(@analyzer.dependencies[bar]).to eq nil
    end

    it 'works with circular require' do
      src = fixtures_dir.join('circular_loader.rb').to_s
      @analyzer.analyze src
      circular = fixtures_dir.join('lib/circular.rb').to_s

      expect(@analyzer.dependencies[src]).to eq [circular]
      expect(@analyzer.dependencies[circular]).to eq [circular]
    end

    it 'raises error of undefined local error' do
      src = fixtures_dir.join('invalid_loader.rb').to_s
      expect {
        @analyzer.analyze src
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
        @analyzer.analyze loaders.last
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
      @analyzer.analyze src
      foo = fixtures_dir.join('lib/foo.rb').to_s
      bar = fixtures_dir.join('lib/bar.rb').to_s

      expect(@analyzer.files).to match_array [src, foo, bar]
    end

    it 'skips file with no require' do
      src = fixtures_dir.join('nil_loader.rb').to_s
      @analyzer.analyze src

      expect(@analyzer.files).to eq []
    end

    it 'preserves relative path' do
      dir = './spec/fixtures'
      src = File.join(dir, 'relative_loader.rb')
      @analyzer.analyze src
      foo = File.join(dir, 'lib/foo.rb')
      bar = fixtures_dir.join('lib/bar.rb').to_s

      expect(@analyzer.files).to eq [src, foo, bar]
    end

    it 'excludes analyzing files in excepted_files' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      MotionBlender.config.excepted_files << src
      @analyzer.analyze src

      expect(@analyzer.files).to match_array []
    end

    it 'excludes required files in excepted_files' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      foo = fixtures_dir.join('lib/foo.rb').to_s
      bar = fixtures_dir.join('lib/bar.rb').to_s
      MotionBlender.config.excepted_files << bar
      @analyzer.analyze src

      expect(@analyzer.files).to match_array [src, foo]
    end

    it 'excludes required args in builtin_features' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      foo = fixtures_dir.join('lib/foo.rb').to_s
      MotionBlender.config.builtin_features << 'bar'
      @analyzer.analyze src

      expect(@analyzer.files).to match_array [src, foo]
    end
  end
end
