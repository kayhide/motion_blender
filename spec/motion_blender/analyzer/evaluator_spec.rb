require 'spec_helper'
require 'motion_blender/analyzer/evaluator'

module MotionBlender
  describe Analyzer::Evaluator do
    let(:file) { 'test/loader.rb' }

    before do
      allow_any_instance_of(Interpreters::RequireInterpreter)
        .to receive(:resolve_path) { |_, arg| arg }
    end

    describe '#run' do
      it 'sets requires' do
        source = Source.parse('require "foo"')
        evaluator = described_class.new(source)

        evaluator.run
        expect(evaluator.requires).to all be_a Require
        expect(evaluator.requires.map(&:arg)).to eq %w(foo)
      end

      it 'evals inner expressions' do
        source = Source.parse('require "foo" + "bar"')
        evaluator = described_class.new(source)

        evaluator.run
        expect(evaluator.requires.map(&:arg)).to eq %w(foobar)
      end

      it 'evals __FILE__' do
        source = Source.parse('require __FILE__', file: file)
        evaluator = described_class.new(source)

        evaluator.run
        expect(evaluator.requires.map(&:arg)).to eq %w(test/loader.rb)
      end

      it 'evals __ORIGINAL__ using OriginalInterpreter' do
        source = Source.parse('require __ORIGINAL__', file: file)
        evaluator = described_class.new(source)

        expect_any_instance_of(Interpreters::OriginalInterpreter)
          .to receive(:interpret) { 'test/original.rb' }
        evaluator.run
        expect(evaluator.requires.map(&:arg)).to eq %w(test/original.rb)
      end

      it 'works with outer loop' do
        root = Source.parse(<<-EOS.strip_heredoc)
          ['nice', 'good'].each { |x|
            ['salt', 'pepper'].each { |f| require [x, f].join('_') }
          }
        EOS

        source = root.children.last.children.last
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

        root = Source.parse(<<-EOS.strip_heredoc)
          if RUBY_PLATFORM == 'java'
            require 'java'
          else
            require 'common'
          end
        EOS
        source = root.children[1]
        evaluator = described_class.new(source)
        evaluator.run

        expect(evaluator.requires.map(&:arg)).to eq %w(common)
      end

      it 'works with rescue clause' do
        allow_any_instance_of(Require)
          .to receive(:file).and_raise(LoadError)
        root = Source.parse(<<-EOS.strip_heredoc)
          begin
            require 'non_existant'
          rescue LoadError
          end
        EOS

        source = root.children.first.children.first
        evaluator = described_class.new(source)
        evaluator.run
        expect(evaluator.requires).to eq []
      end

      it 'fails when require arg is invalid' do
        source = Source.parse('require invalid')
        evaluator = described_class.new(source)

        expect {
          evaluator.run
        }.to raise_error { |error|
          expect(error).to be_a LoadError
        }
      end

      it 'evaluates same source only once' do
        root = Source.parse(<<-EOS.strip_heredoc)
          if false
            require invalid_1
            require invalid_2
          end
        EOS

        expect(root).to receive(:evaluated!).once.and_call_original
        described_class.new(root.children[1].children[0]).run
        described_class.new(root.children[1].children[1]).run
      end
    end

    describe '#dynamic?' do
      it 'returns false for static expression' do
        source = Source.parse('require "foo" + "bar"')
        evaluator = described_class.new(source)

        expect(evaluator.dynamic?).to eq false
      end

      it 'returns true with outer loop' do
        root = Source.parse(<<-EOS.strip_heredoc)
          ['nice', 'good'].each { |x|
            ['salt', 'pepper'].each { |f| require [x, f].join('_') }
          }
        EOS

        source = root.children.last.children.last
        evaluator = described_class.new(source)

        evaluator.run
        expect(evaluator.dynamic?).to eq true
      end

      it 'returns true with rescue clause' do
        allow_any_instance_of(Require)
          .to receive(:file).and_raise(LoadError)
        root = Source.parse(<<-EOS.strip_heredoc)
          begin
            require 'non_existant'
          rescue LoadError
          end
        EOS

        source = root.children.first.children.first
        evaluator = described_class.new(source)
        evaluator.run
        expect(evaluator.dynamic?).to eq true
      end
    end
  end
end
