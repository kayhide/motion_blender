require 'spec_helper'
require 'motion_blender/analyzer/evaluator'

describe MotionBlender::Analyzer::Evaluator do
  let(:file) { 'test/loader.rb' }

  before do
    allow_any_instance_of(MotionBlender::Analyzer::Require)
      .to receive(:file) { |req| req.arg }
  end

  describe '#parse_args' do
    it 'returns requires' do
      ast = ::Parser::CurrentRuby.parse('require "foo"')
      evaluator = MotionBlender::Analyzer::Evaluator.new(file, ast)

      expect(evaluator.parse_args).to all be_a MotionBlender::Analyzer::Require
      expect(evaluator.parse_args.map(&:arg)).to eq %w(foo)
    end

    it 'evals inner expressions' do
      ast = ::Parser::CurrentRuby.parse('require "foo" + "bar"')
      evaluator = MotionBlender::Analyzer::Evaluator.new(file, ast)

      expect(evaluator.parse_args.map(&:arg)).to eq %w(foobar)
    end

    it 'evals __FILE__' do
      ast = ::Parser::CurrentRuby.parse('require __FILE__')
      evaluator = MotionBlender::Analyzer::Evaluator.new(file, ast)

      expect(evaluator.parse_args.map(&:arg)).to eq %w(test/loader.rb)
    end

    it 'works with outer loop' do
      src = ::Parser::CurrentRuby.parse(<<-EOS.strip_heredoc)
        ['nice', 'good'].each { |x|
          ['salt', 'pepper'].each { |f| require [x, f].join('_') }
        }
      EOS

      stack = [src, src.children.last]
      ast = src.children.last.children.last
      evaluator = MotionBlender::Analyzer::Evaluator.new(file, ast, stack)

      expect(evaluator.parse_args.map(&:arg))
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

      stack = [src, src.children.first]
      ast = src.children.first.children.first
      evaluator = MotionBlender::Analyzer::Evaluator.new(file, ast, stack)

      expect(evaluator.parse_args).to eq []
    end

    it 'fails when require arg is invalid' do
      ast = ::Parser::CurrentRuby.parse('require invalid')
      evaluator = MotionBlender::Analyzer::Evaluator.new(file, ast)

      expect {
        evaluator.parse_args
      }.to raise_error { |error|
        expect(error).to be_a LoadError
      }
    end
  end
end
