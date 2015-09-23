require 'spec_helper'

describe MotionBlender::Analyzer do
  before do
    @analyzer = MotionBlender::Analyzer.new
    $:.unshift fixtures_dir.join('lib')
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

    it 'excludes analyzing files in exclude_files' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      @analyzer.exclude_files << src
      @analyzer.analyze src

      expect(@analyzer.files).to match_array []
    end

    it 'excludes required files in exclude_files' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      foo = fixtures_dir.join('lib/foo.rb').to_s
      bar = fixtures_dir.join('lib/bar.rb').to_s
      @analyzer.exclude_files << bar
      @analyzer.analyze src

      expect(@analyzer.files).to match_array [src, foo]
    end
  end
end
