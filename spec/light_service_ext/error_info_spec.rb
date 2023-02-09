RSpec.describe LightServiceExt::ErrorInfo do
  subject(:instance) { error_info_class.new(error, ctx: ctx, message: message_override, fatal: fatal) }

  let(:value) { 'some-value' }
  let(:ctx) { { key: value } }
  let(:message_override) { nil }
  let(:message) { 'some-error' }
  let(:fatal) { nil }
  let(:backtrace) { ['some-backtrace-item'] }
  let(:error) { StandardError.new(message) }
  let(:error_info_class) { Class.new(described_class) }

  before do
    error.set_backtrace(backtrace)
  end

  describe '#type' do
    it 'returns error class name' do
      expect(instance.type).to eql(error.class.name)
    end
  end

  describe '#title' do
    it 'returns error title with class name and message' do
      expect(instance.title).to eql("#{error.class.name} : #{message}")
    end
  end

  describe 'message' do
    it 'returns error message' do
      expect(instance.message).to eql(message)
    end

    context 'with message override' do
      let(:message_override) { 'some-other-message' }

      it 'returns error message override' do
        expect(instance.message).to eql(message_override)
      end
    end
  end

  describe '#error' do
    it 'returns original exception' do
      expect(instance.error).to eql(error)
    end
  end

  describe '#fatal_error?' do
    it 'returns true' do
      expect(instance).to be_fatal_error
    end

    context 'with non fatal error' do
      let(:error) { ArgumentError.new(message) }

      before { error_info_class.non_fatal_errors = [ArgumentError] }

      context 'with fatal passed as arg' do
        let(:fatal) { true }

        it 'returns true' do
          expect(instance).to be_fatal_error
        end
      end

      it 'returns false' do
        expect(instance).not_to be_fatal_error
      end
    end
  end

  describe '#error_summary' do
    it 'returns summary of error' do
      expect(instance.error_summary).to eql(<<~TEXT
        =========== SERVER ERROR FOUND: StandardError : some-error ===========

        some-backtrace-item
        ========================================================

        FULL STACK TRACE
        some-backtrace-item

        ========================================================
      TEXT
                                           )
    end
  end
end
