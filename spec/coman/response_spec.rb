require_relative '../../lib/coman/response'

RSpec.describe Coman::Response do
  describe '#initialize' do
    context 'with no args' do
      subject { -> { described_class.new } }
      it { expect(subject).to raise_error(ArgumentError) }
    end

    context ':code arg' do
      context 'with no :code' do
        context 'with :status => :ok' do
          subject { described_class.new(status: :ok) }

          it { expect(subject.code).to eql 200 }
        end

        context 'with :status => :error' do
          subject { described_class.new(status: :error) }

          it { expect(subject.code).to eql 400 }
        end
      end

      context 'with invalid :code' do
        subject { -> { described_class.new(code: 'wrong code', status: :ok) } }

        it do
          error_class   = described_class::InvalidCodeError
          error_message = 'Invalid code (code=wrong code), has to be in [200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418, 421, 422, 423, 424, 426, 428, 429, 431, 451, ok, created, accepted, non_authoritative_information, no_content, reset_content, partial_content, multi_status, already_reported, im_used, bad_request, unauthorized, payment_required, forbidden, not_found, method_not_allowed, not_acceptable, proxy_authentication_required, request_time_out, conflict, gone, length_required, precondition_failed, payload_too_large, uri_too_long, unsupported_media_type, range_not_satisfiable, expectation_failed, i_m_a_teapot, misdirected_request, unprocessable_entity, locked, failed_dependency, upgrade_required, precondition_required, too_many_requests, request_header_fields_too_large, unavailable_for_legal_reasons]'
          expect(subject).to raise_error(error_class, error_message)
        end
      end

      context 'with valid :code' do
        it 'returns integer' do
          [200, :ok].each do |code|
            instance = described_class.new(code: code, status: :ok)
            expect(instance.code).to eql 200
          end

          [400, :bad_request].each do |code|
            instance = described_class.new(code: code, status: :error)
            expect(instance.code).to eql 400
          end
        end

        context 'with status not matching code' do
          context 'with :code => 400, :status => :ok' do
            subject { -> { described_class.new(code: 400, status: :ok) } }

            it do
              error_class   = described_class::StatusAndCodeMismatchError
              error_message = 'Status (status=ok) and code (code=400) don\'t match'
              expect(subject).to raise_error(error_class, error_message)
            end
          end

          context 'with :code => 200, :status => :error' do
            subject { -> { described_class.new(code: 200, status: :error) } }

            it do
              error_class   = described_class::StatusAndCodeMismatchError
              error_message = 'Status (status=error) and code (code=200) don\'t match'
              expect(subject).to raise_error(error_class, error_message)
            end
          end
        end
      end
    end

    context ':status arg' do
      context 'with no :status' do
        subject { -> { described_class.new(messages: ['message'], result: 'string') } }
        it { expect(subject).to raise_error(ArgumentError) }
      end

      context 'with invalid :status' do
        subject { -> { described_class.new(status: 'wrong status') } }

        it do
          error_class   = described_class::InvalidStatusError
          error_message = 'Invalid status (status=wrong status), has to be in [error, ok]'
          expect(subject).to raise_error(error_class, error_message)
        end
      end

      context 'with valid :status and no other args' do
        let(:args) { { status: status } }
        let(:status) { :ok }
        subject { described_class.new(args).status }

        it { expect{ described_class.new(args) }.to_not raise_error }

        context 'with :status => :ok' do
          let(:status) { :ok }
          it { expect(subject).to eql :ok }
        end

        context 'with :status => "ok"' do
          let(:status) { 'ok' }
          it { expect(subject).to eql :ok }
        end

        context 'with :status => :error' do
          let(:status) { :error }
          it { expect(subject).to eql :error }
        end

        context 'with :status => "error"' do
          let(:status) { 'error' }
          it { expect(subject).to eql :error }
        end
      end
    end

    context ':messages arg' do
      subject { described_class.new(args).messages }

      context 'with no :messages' do
        let(:args) { { status: :ok } }
        it { expect(subject).to eq [] }
      end

      context 'with :messages => ["foobar"]' do
        let(:args) { { messages: ['foobar'], status: :ok } }
        it { expect(subject).to eq ['foobar'] }
      end

      context 'with invalid :messages' do
        let(:error_class) { described_class::InvalidMessageError }

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

  describe '#ok' do
    context 'with block' do
      context 'with no code arg' do
        it 'yields block if status=:ok' do
          args_to_returned_values = {
            { status: :ok } => [nil, []],
            { status: :ok, result: 'result' } => ['result', []],
            { messages: ['foobar'], status: :ok } => [nil, ['foobar']],
            { messages: ['foobar'], status: :ok, result: 'result' } => ['result', ['foobar']],
          }
          args_to_returned_values.each do |args, returned_values|
            expect{ |block| described_class.new(args).ok(&block)}.to yield_with_args(*returned_values)
          end
        end

        it 'yields for any success code' do
          args_to_returned_values = {
            { code: 200, status: :ok } => [nil, []],
            { code: 201, status: :ok } => [nil, []],
            { code: :ok, status: :ok } => [nil, []],
            { code: :created, status: :ok } => [nil, []],
          }
          args_to_returned_values.each do |args, returned_values|
            expect{ |block| described_class.new(args).ok(&block)}.to yield_with_args(*returned_values)
          end
        end

        it 'does not yield block if status=:error' do
          expect{ |block| described_class.new(status: :error).ok(&block)}.to_not yield_with_args
        end
      end

      context 'with code arg' do
        it 'yields only if response code matches given code' do
          expect do |block|
            described_class.new(code: 201, status: :ok).ok(201, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: 201, status: :ok).ok(:created, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: :created, status: :ok).ok(201, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: :created, status: :ok).ok(:created, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: 200, status: :ok).ok(201, &block)
          end.to_not yield_with_args
        end
      end
    end


    context 'with no block' do
      let(:instance) { described_class.new(status: :ok) }

      it do
        expect{ instance.ok }.to_not raise_error
        expect( instance.ok ).to eql instance
      end
    end
  end

  describe '#error' do
    context 'with block' do
      context 'with no code arg' do
        it 'yields block if status=:error' do
          args_to_returned_values = {
            { status: :error } => [nil, []],
            { status: :error, result: 'result' } => ['result', []],
            { messages: ['foobar'], status: :error } => [nil, ['foobar']],
            { messages: ['foobar'], status: :error, result: 'result' } => ['result', ['foobar']],
          }
          args_to_returned_values.each do |args, returned_values|
            expect{ |block| described_class.new(args).error(&block)}.to yield_with_args(*returned_values)
          end
        end

        it 'yields for any error code' do
          args_to_returned_values = {
            { code: 400, status: :error } => [nil, []],
            { code: 401, status: :error } => [nil, []],
            { code: :bad_request, status: :error } => [nil, []],
            { code: :unauthorized, status: :error } => [nil, []],
          }
          args_to_returned_values.each do |args, returned_values|
            expect{ |block| described_class.new(args).error(&block)}.to yield_with_args(*returned_values)
          end
        end

        it 'does not yield block if status=:ok' do
          expect{ |block| described_class.new(status: :ok).error(&block)}.to_not yield_with_args
        end
      end

      context 'with code arg' do
        it 'yields only if response code matches given code' do
          expect do |block|
            described_class.new(code: 401, status: :error).error(401, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: 401, status: :error).error(:unauthorized, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: :unauthorized, status: :error).error(401, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: :unauthorized, status: :error).error(:unauthorized, &block)
          end.to yield_with_args(nil, [])

          expect do |block|
            described_class.new(code: 400, status: :error).error(401, &block)
          end.to_not yield_with_args
        end
      end
    end

    context 'with no block' do
      let(:instance) { described_class.new(status: :ok) }

      it do
        expect{ instance.ok }.to_not raise_error
        expect( instance.ok ).to eql instance
      end
    end
  end

  describe '.ok' do
    it 'builds new Response with status=:ok' do
      expect(described_class).to receive(:new).with({ status: :ok })
      described_class.ok

      expect(described_class).to receive(:new).with({ messages: ['foobar'], status: :ok })
      described_class.ok(messages: ['foobar'])

      expect(described_class).to receive(:new).with({ messages: [], status: :ok })
      described_class.ok(messages: [])

      expect(described_class).to receive(:new).with({ status: :ok, result: 'result' })
      described_class.ok(result: 'result')

      expect(described_class).to receive(:new).with({ status: :ok, result: nil })
      described_class.ok(result: nil)

      expect(described_class).to receive(:new).with({ code: 400, status: :ok })
      described_class.ok(code: 400)

      expect(described_class).to receive(:new).with({ code: 401, messages: [], status: :ok, result: 'result' })
      described_class.ok(code: 401, messages: [], result: 'result')
    end
  end

  describe '.error' do
    it 'builds new Response with status=:ok' do
      expect(described_class).to receive(:new).with({ status: :error })
      described_class.error

      expect(described_class).to receive(:new).with({ messages: ['foobar'], status: :error })
      described_class.error(messages: ['foobar'])

      expect(described_class).to receive(:new).with({ messages: [], status: :error })
      described_class.error(messages: [])

      expect(described_class).to receive(:new).with({ status: :error, result: 'result' })
      described_class.error(result: 'result')

      expect(described_class).to receive(:new).with({ status: :error, result: nil })
      described_class.error(result: nil)

      expect(described_class).to receive(:new).with({ code: 400, status: :error })
      described_class.error(code: 400)

      expect(described_class).to receive(:new).with({ code: 401, messages: [], status: :error, result: 'result' })
      described_class.error(code: 401, messages: [], result: 'result')
    end
  end
end
