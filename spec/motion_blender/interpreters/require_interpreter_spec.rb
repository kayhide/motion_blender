require 'spec_helper'

module MotionBlender
  describe Interpreters::RequireInterpreter do
    use_lib_dir

    let(:requires) { [] }

    let(:file) { fixtures_dir.join('foo_loader.rb').to_s }

    subject {
      described_class.new(double).tap do |interpreter|
        allow(interpreter).to receive(:file) { file }
        allow(interpreter).to receive(:requires) { requires }
      end
    }

    describe '#interpret' do
      it 'adds require to requires' do
        expect {
          subject.interpret 'foo'
        }.to change(requires, :count).by(1)
      end
    end

    describe '#resolve_path' do
      it 'returns pathname' do
        foo = fixtures_dir.join('lib/foo.rb').to_s
        expect(subject.resolve_path('foo')).to eq foo
      end

      describe 'with motion dir' do
        before do
          motion_dir = fixtures_dir.join('motion').to_s
          MotionBlender.config.motion_dirs << motion_dir
        end

        it 'returns pathname found in motion dir' do
          foo = fixtures_dir.join('motion/foo.rb').to_s
          expect(subject.resolve_path('foo')).to eq foo
        end
      end

      describe 'when required feature is missing' do
        it 'fails' do
          arg = 'missing_feature'
          expect {
            subject.resolve_path(arg)
          }.to raise_error { |error|
            expect(error).to be_a LoadError
            expect(error.message).to include arg
          }
        end
      end
    end
  end
end
