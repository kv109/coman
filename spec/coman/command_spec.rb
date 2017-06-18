require_relative '../../lib/coman/command'

RSpec.describe Coman::Command do
  let(:extended_class) { Class.new.include(described_class) }
  let(:extended_instance) { extended_class.new }

  it { expect(extended_instance).to respond_to(:response) }

  context 'when extended instance already implements #response method' do
    let(:extended_instance) do
      extended_class.new.tap do
        def response
        end
      end
    end

    it do
      expect{ extended_instance }.to raise_error(described_class::CannotOverrideMethod)
    end
  end
end
