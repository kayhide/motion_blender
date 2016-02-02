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
        expect(source.child_at(1, 2).wrapping_modules)
          .to eq [%w(module Hoge), %w(class Piyo)]
      end
    end
  end

  describe '#referring_constants' do
    it 'captures grounded constants' do
      source = Source.parse(<<-EOS.strip_heredoc)
        Hoge
        Piyo
      EOS

      expect(source.referring_constants).to eq [[[], 'Hoge'], [[], 'Piyo']]
    end

    it 'captures module constants' do
      source = Source.parse(<<-EOS.strip_heredoc)
        module Hoge; end
        class Piyo; end
      EOS

      expect(source.referring_constants).to eq [[[], 'Hoge'], [[], 'Piyo']]
    end

    it 'captures wrapped constants' do
      source = Source.parse(<<-EOS.strip_heredoc)
        module Alpha
          module Beta
            Hoge
          end
        end
      EOS

      expect(source.referring_constants)
        .to eq [[[], 'Alpha'], [%w(Alpha), 'Beta'], [%w(Alpha Beta), 'Hoge']]
    end

    it 'captures connected modules' do
      source = Source.parse(<<-EOS.strip_heredoc)
        Hoge::Piyo::Fuga
      EOS

      expect(source.referring_constants)
        .to eq [[[], 'Hoge'], [[], 'Hoge::Piyo'], [[], 'Hoge::Piyo::Fuga']]
    end

    it 'captures connected module on module definition' do
      source = Source.parse(<<-EOS.strip_heredoc)
        module Alpha
          module Hoge::Piyo
          end
        end
      EOS

      expect(source.referring_constants)
        .to eq [[[], 'Alpha'], [%w(Alpha), 'Hoge'], [%w(Alpha), 'Hoge::Piyo']]
    end

    it 'captures derived class base' do
      source = Source.parse(<<-EOS.strip_heredoc)
        module Alpha
          class Hoge < Piyo
          end
        end
      EOS

      expect(source.referring_constants)
        .to eq [[[], 'Alpha'], [%w(Alpha), 'Hoge'], [%w(Alpha), 'Piyo']]
    end

    it 'ignores defining constant' do
      source = Source.parse(<<-EOS.strip_heredoc)
        Alpha = :alpha
      EOS

      expect(source.referring_constants).to eq []
    end
  end
end
