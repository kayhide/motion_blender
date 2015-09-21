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

      expect(@analyzer.requires[src]).to eq %w(foo)
      expect(@analyzer.requires[foo]).to eq %w(bar)
      expect(@analyzer.requires[bar]).to eq nil
    end

    it 'captures requires' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      @analyzer.analyze src
      foo = fixtures_dir.join('lib/foo.rb').to_s
      bar = fixtures_dir.join('lib/bar.rb').to_s

      expect(@analyzer.requires[src]).to eq %w(foo)
      expect(@analyzer.requires[foo]).to eq %w(bar)
      expect(@analyzer.requires[bar]).to eq nil
    end

    it 'works with circular require' do
      src = fixtures_dir.join('circular_loader.rb').to_s
      @analyzer.analyze src
      circular = fixtures_dir.join('lib/circular.rb').to_s

      expect(@analyzer.requires[src]).to eq %w(circular)
      expect(@analyzer.requires[circular]).to eq %w(circular)
    end

    it 'works with undefined constant' do
      src = fixtures_dir.join('undefined_loader.rb').to_s
      expect {
        @analyzer.analyze src
      }.not_to raise_error
    end
  end

  describe '#files' do
    it 'returns all required files' do
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
  end

  describe '#create_dependencies' do
    it 'creates dependencies' do
      src = fixtures_dir.join('foo_loader.rb').to_s
      foo = fixtures_dir.join('lib/foo.rb').to_s
      allow(@analyzer).to receive(:files) { [src, foo] }
      allow(@analyzer).to receive(:requires) { { src => %w(foo) } }

      @analyzer.create_dependencies
      expect(@analyzer.dependencies[src]).to eq [foo]
    end
  end
end
