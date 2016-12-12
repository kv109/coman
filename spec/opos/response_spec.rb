require_relative '../../lib/opos/response'

RSpec.describe Opos::Response do
  context '#initialize' do
    subject { -> { described_class.new(args) } }

    context 'with no args' do
      subject { -> { described_class.new } }
      it { expect(subject).to raise_error(ArgumentError) }
    end

    context ':status arg' do
      context 'with no :status' do
        let(:args) { { messages: ['message'], value: 'string' } }
        it { expect(subject).to raise_error(ArgumentError) }
      end

      context 'with invalid :status' do
        let(:args) { { status: status } }
        let(:status) { 'wrong status' }

        it do
          error_class   = Opos::Response::InvalidStatusError
          error_message = 'Invalid status (status=wrong status), has to be in [error, ok])'
          expect(subject).to raise_error(error_class, error_message)
        end
      end

      context 'with valid :status and no other args' do
        let(:args) { { status: status } }
        let(:status) { :ok }
        subject { described_class.new(args).status }

        it { expect{ described_class.new(args) }.to_not raise_error }

        context 'with :status => :ok arg' do
          let(:status) { :ok }
          it { expect(subject).to eql :ok }
        end

        context 'with :status => "ok" arg' do
          let(:status) { 'ok' }
          it { expect(subject).to eql :ok }
        end

        context 'with :status => :error arg' do
          let(:status) { :error }
          it { expect(subject).to eql :error }
        end

        context 'with :status => "error" arg' do
          let(:status) { 'error' }
          it { expect(subject).to eql :error }
        end
      end
    end

    context ':messages' do
      subject { described_class.new(args).messages }

      context 'with no :messages' do
        let(:args) { { status: :ok } }
        it { expect(subject).to eq [] }
      end

      context 'with :messages => ["foobar"] arg' do
        let(:args) { { messages: ['foobar'], status: :ok } }
        it { expect(subject).to eq ['foobar'] }
      end

      context 'with invalid :messages' do
        let(:error_class) { Opos::Response::InvalidMessageError }

        context 'with message=:not_string' do
          let(:args) { { messages: [:not_string], status: :ok } }

          it do
            error_message = 'Invalid message (message=not_string:Symbol), has to be non-empty String'
            expect{ described_class.new(args) }.to raise_error(error_class, error_message)
          end
        end

        context 'with message=""' do
          let(:args) { { messages: [''], status: :ok } }

          it do
            error_message = 'Invalid message (message=[empty string]), has to be non-empty String'
            expect{ described_class.new(args) }.to raise_error(error_class, error_message)
          end
        end
      end
    end
  end
end
