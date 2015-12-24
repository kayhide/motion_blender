require 'spec_helper'
require 'motion_blender/analyzer/evaluator'

describe MotionBlender::Analyzer::Evaluator do
  let(:file) { 'test/loader.rb' }

  before do
    allow_any_instance_of(MotionBlender::Analyzer::Require)
      .to receive(:file) { |req| req.arg }
  end

  describe '#run' do
    it 'sets requires' do
      ast = ::Parser::CurrentRuby.parse('require "foo"')
      source = MotionBlender::Analyzer::Source.new(file: file, ast: ast)
      evaluator = MotionBlender::Analyzer::Evaluator.new(source)

      evaluator.run
      expect(evaluator.requires).to all be_a MotionBlender::Analyzer::Require
      expect(evaluator.requires.map(&:arg)).to eq %w(foo)
    end

    it 'evals inner expressions' do
      ast = ::Parser::CurrentRuby.parse('require "foo" + "bar"')
      source = MotionBlender::Analyzer::Source.new(file: file, ast: ast)
      evaluator = MotionBlender::Analyzer::Evaluator.new(source)

      evaluator.run
      expect(evaluator.requires.map(&:arg)).to eq %w(foobar)
    end

    it 'evals __FILE__' do
      ast = ::Parser::CurrentRuby.parse('require __FILE__')
      source = MotionBlender::Analyzer::Source.new(file: file, ast: ast)
      evaluator = MotionBlender::Analyzer::Evaluator.new(source)

      evaluator.run
      expect(evaluator.requires.map(&:arg)).to eq %w(test/loader.rb)
    end

    it 'evals __ORIGINAL__ using OriginalFinder' do
      ast = ::Parser::CurrentRuby.parse('require __ORIGINAL__')
      source = MotionBlender::Analyzer::Source.new(file: file, ast: ast)
      evaluator = MotionBlender::Analyzer::Evaluator.new(source)

      expect(MotionBlender::Analyzer::OriginalFinder)
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

      source = MotionBlender::Analyzer::Source.new(file: file, ast: src)
      source = MotionBlender::Analyzer::Source.new(
        file: file, ast: src.children.last, parent: source)
      source = MotionBlender::Analyzer::Source.new(
        file: file, ast: src.children.last.children.last, parent: source)
      evaluator = MotionBlender::Analyzer::Evaluator.new(source)
      evaluator.run

      expect(evaluator.requires.map(&:arg))
        .to eq %w(nice_salt nice_pepper good_salt good_pepper)
    end

    it 'works with rescue clause' do
      allow_any_instance_of(MotionBlender::Analyzer::Require)
        .to receive(:file).and_raise(LoadError)
      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        begin
          require 'non_existant'
        rescue LoadError
        end
      EOS

      source = MotionBlender::Analyzer::Source.new(file: file, ast: src)
      source = MotionBlender::Analyzer::Source.new(
        file: file, ast: src.children.first, parent: source)
      source = MotionBlender::Analyzer::Source.new(
        file: file, ast: src.children.first.children.first, parent: source)
      evaluator = MotionBlender::Analyzer::Evaluator.new(source)
      evaluator.run
      expect(evaluator.requires).to eq []
    end

    it 'fails when require arg is invalid' do
      ast = ::Parser::CurrentRuby.parse('require invalid')
      source = MotionBlender::Analyzer::Source.new(file: file, ast: ast)
      evaluator = MotionBlender::Analyzer::Evaluator.new(source)

      expect {
        evaluator.run
      }.to raise_error { |error|
        expect(error).to be_a LoadError
      }
    end
  end
end
