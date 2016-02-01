require 'spec_helper'

module MotionBlender
  describe Source do
    describe '#global_constants' do
      it 'finds modules and classes' do
        source = Source.parse(<<-EOS.strip_heredoc)
          module SomeModule
          end
          class SomeClass
          end
        EOS

        expect(source.global_constants).to eq %w(SomeModule SomeClass)
      end

      it 'picks constants uniquely' do
        source = Source.parse(<<-EOS.strip_heredoc)
          module SomeModule
          end
          module SomeModule
          end
        EOS

        expect(source.global_constants).to eq %w(SomeModule)
      end

      it 'rellays to root' do
        root = Source.parse(<<-EOS.strip_heredoc)
          module SomeModule
          end
          class SomeClass
          end
        EOS

        source = root.children.first
        expect(root).to receive(:global_constants).and_call_original
        expect(source.global_constants).to eq %w(SomeModule SomeClass)
      end

      it 'ignores nested constants' do
        source = Source.parse(<<-EOS.strip_heredoc)
          module SomeModule
            module Nested
            end
          end
        EOS

        expect(source.global_constants).to eq %w(SomeModule)
      end

      it 'takes root if connected' do
        source = Source.parse(<<-EOS.strip_heredoc)
          module SomeModule::Nested
          end
        EOS

        expect(source.global_constants).to eq %w(SomeModule)
      end
    end

    describe '#wrapping_modules' do
      it 'returns wrapping modules and classes' do
        source = Source.parse(<<-EOS.strip_heredoc)
          module Hoge
            class Piyo
              1
            end
          end
        EOS

        expect(source.wrapping_modules).to eq []
        expect(source.child_at(1).wrapping_modules).to eq [%w(module Hoge)]
        expect(source.child_at(1, 1).wrapping_modules)
          .to eq [%w(module Hoge), %w(class Piyo)]
      end
    end
  end
end
