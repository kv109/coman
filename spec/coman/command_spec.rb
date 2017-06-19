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

    it { expect(subject).to respond_to(:response) }

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
        let(:class_to_extend) { class_with_instance_method(:call) }
        it { expect { subject }.to_not raise_error }

        context 'and #call returns' do
          let(:class_to_extend) { class_with_instance_method(:call, return_value) }
          context 'nil' do
            let(:return_value) { nil }
            it { expect(subject).to eql(Coman::Response.ok) }
          end

          context 'string' do
            let(:return_value) { 'string' }
            it { expect(subject).to eql(Coman::Response.ok(result: 'string')) }
          end

          context 'integer' do
            let(:return_value) { 109 }
            it { expect(subject).to eql(Coman::Response.ok(result: 109)) }
          end
        end
      end
    end
  end

  def class_with_instance_method(method_name, return_value = nil)
    Class.new do
      define_method method_name do
        return_value
      end
    end
  end
end
