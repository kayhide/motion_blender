require 'spec_helper'

module MotionBlender
  describe Callbacks do
    use_lib_dir

    let(:analyzer) { Analyzer.new }

    before do
      Analyzer::Parser.reset_callbacks :parse
      Analyzer::Require.reset_callbacks :require
    end

    describe '.on_parse' do
      let(:src) { fixtures_dir.join('foo_loader.rb').to_s }

      it 'runs given block with parser arg' do
        parsers = []
        MotionBlender.on_parse { |parser| parsers << parser }
        analyzer.analyze src

        expect(parsers.length).to eq 3
        expect(parsers).to all be_a Analyzer::Parser

        files = [src] + %w(foo.rb bar.rb).map { |f| lib_dir.join(f).to_s }
        expect(parsers.map(&:file)).to eq files
      end

      it 'filters by file' do
        parsers = []
        file = lib_dir.join('bar.rb').to_s
        MotionBlender.on_parse(file) { |parser| parsers << parser }
        analyzer.analyze src

        expect(parsers.length).to eq 1
        expect(parsers.first.file).to eq file
      end
    end

    describe '.on_require' do
      let(:src) { fixtures_dir.join('foo_loader.rb').to_s }

      it 'runs given block with require arg' do
        reqs = []
        MotionBlender.on_require { |req| reqs << req }
        analyzer.analyze src

        expect(reqs.length).to eq 2
        expect(reqs).to all be_a Analyzer::Require
        expect(reqs.map(&:arg)).to eq %w(foo bar)
      end

      it 'filters by file' do
        reqs = []
        MotionBlender.on_require('foo') { |req| reqs << req }
        analyzer.analyze src

        expect(reqs.length).to eq 1
        req = reqs.first
        expect(req.arg).to eq 'foo'
        expect(req.loader).to eq src
        expect(req.file).to eq lib_dir.join('foo.rb').to_s
      end
    end
  end
end
