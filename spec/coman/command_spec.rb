require_relative '../../lib/coman/command'

RSpec.describe Coman::Command do
  describe 'extended instance' do
    subject { class_to_extend.new.extend(described_class) }

    let(:class_to_extend) do
      Class.new do
        def call
        end
      end
    end

    it { expect(subject.public_methods).to include(:response) }

    context 'when already implements #response' do
      let(:class_to_extend) do
        Class.new do
          def response
          end
        end
      end

      it do
        expect { subject }.to raise_error(described_class::CannotOverrideMethod)
      end
    end
  end

  describe '#response' do
    subject do
      class_to_extend.new.extend(described_class).response
    end

    context 'when extended class' do
      context 'does not implement #call' do
        let(:class_to_extend) { Object }

        it do
          error_message = 'Coman::Command expects Object to implement #call'
          error_class   = NotImplementedError
          expect { subject }.to raise_error(error_class, error_message)
        end
      end

      context 'implements #call' do
        let(:class_to_extend) do
          Class.new do
            def call
            end
          end
        end

        it { expect { subject }.to_not raise_error }
      end
    end
  end
end
