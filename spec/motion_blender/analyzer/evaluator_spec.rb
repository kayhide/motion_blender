require 'spec_helper'
require 'motion_blender/analyzer/evaluator'

describe MotionBlender::Analyzer::Evaluator do
  Source = MotionBlender::Analyzer::Source
  Require = MotionBlender::Analyzer::Require
  OriginalFinder = MotionBlender::Analyzer::OriginalFinder

  let(:file) { 'test/loader.rb' }

  before do
    allow_any_instance_of(Require).to receive(:file) { |req| req.arg }
  end

  describe '#run' do
    it 'sets requires' do
      ast = ::Parser::CurrentRuby.parse('require "foo"')
      source = Source.new(ast: ast)
      evaluator = described_class.new(source)

      evaluator.run
      expect(evaluator.requires).to all be_a Require
      expect(evaluator.requires.map(&:arg)).to eq %w(foo)
    end

    it 'evals inner expressions' do
      ast = ::Parser::CurrentRuby.parse('require "foo" + "bar"')
      source = Source.new(ast: ast)
      evaluator = described_class.new(source)

      evaluator.run
      expect(evaluator.requires.map(&:arg)).to eq %w(foobar)
    end

    it 'evals __FILE__' do
      ast = ::Parser::CurrentRuby.parse('require __FILE__')
      source = Source.new(file: file, ast: ast)
      evaluator = described_class.new(source)

      evaluator.run
      expect(evaluator.requires.map(&:arg)).to eq %w(test/loader.rb)
    end

    it 'evals __ORIGINAL__ using OriginalFinder' do
      ast = ::Parser::CurrentRuby.parse('require __ORIGINAL__')
      source = Source.new(file: file, ast: ast)
      evaluator = described_class.new(source)

      expect(OriginalFinder)
        .to receive(:new).with(file) { double(find: 'test/original.rb') }
      evaluator.run
      expect(evaluator.requires.map(&:arg)).to eq %w(test/original.rb)
    end

    it 'works with outer loop' do
      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        ['nice', 'good'].each { |x|
          ['salt', 'pepper'].each { |f| require [x, f].join('_') }
        }
      EOS

      source = Source.new(ast: src).children.last.children.last
      evaluator = described_class.new(source)
      evaluator.run

      expect(evaluator.requires.map(&:arg))
        .to eq %w(nice_salt nice_pepper good_salt good_pepper)
    end

    it 'works with if statement' do
      allow_any_instance_of(Require)
        .to receive(:file) do |req|
        fail LoadError if req.arg == 'java'
        req.arg
      end

      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        if RUBY_PLATFORM == 'java'
          require 'java'
        else
          require 'common'
        end
      EOS
      source = Source.new(ast: src).children[1]
      evaluator = described_class.new(source)
      evaluator.run

      expect(evaluator.requires.map(&:arg)).to eq %w(common)
    end

    it 'works with rescue clause' do
      allow_any_instance_of(Require).to receive(:file).and_raise(LoadError)
      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        begin
          require 'non_existant'
        rescue LoadError
        end
      EOS

      source = Source.new(ast: src).children.first.children.first
      evaluator = described_class.new(source)
      evaluator.run
      expect(evaluator.requires).to eq []
    end

    it 'fails when require arg is invalid' do
      ast = ::Parser::CurrentRuby.parse('require invalid')
      source = Source.new(ast: ast)
      evaluator = described_class.new(source)

      expect {
        evaluator.run
      }.to raise_error { |error|
        expect(error).to be_a LoadError
      }
    end

    it 'evaluates same source only once' do
      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        if false
          require invalid_1
          require invalid_2
        end
      EOS

      root = Source.new(ast: src)
      expect(root).to receive(:evaluated!).once.and_call_original
      described_class.new(root.children[1].children[0]).run
      described_class.new(root.children[1].children[1]).run
    end
  end

  describe '#dynamic?' do
    it 'returns false for static expression' do
      ast = ::Parser::CurrentRuby.parse('require "foo" + "bar"')
      source = Source.new(ast: ast)
      evaluator = described_class.new(source)

      expect(evaluator.dynamic?).to eq false
    end

    it 'returns true with outer loop' do
      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        ['nice', 'good'].each { |x|
          ['salt', 'pepper'].each { |f| require [x, f].join('_') }
        }
      EOS

      source = Source.new(ast: src).children.last.children.last
      evaluator = described_class.new(source)

      evaluator.run
      expect(evaluator.dynamic?).to eq true
    end

    it 'returns true with rescue clause' do
      allow_any_instance_of(Require).to receive(:file).and_raise(LoadError)
      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        begin
          require 'non_existant'
        rescue LoadError
        end
      EOS

      source = Source.new(ast: src).children.first.children.first
      evaluator = described_class.new(source)
      evaluator.run
      expect(evaluator.dynamic?).to eq true
    end
  end
end
