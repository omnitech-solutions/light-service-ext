# rubocop:disable Metrics/ModuleLength
module LightServiceExt
  RSpec.describe ContextError do
    let(:value) { 'some-value' }
    let(:ctx) { ApplicationContext.make({ key: value }) }
    let(:message) { 'some-error' }
    let(:message_override) { nil }
    let(:error) { StandardError.new(message) }
    let(:fatal) { nil }
    let(:backtrace) { ['some-backtrace-item'] }
    let(:instance) { described_class.new(error: error, ctx: ctx, message: message_override, fatal: fatal) }
    let(:organizer_class) { ApplicationOrganizer }
    let(:action_class) { ApplicationAction }
    let(:param_error_value) { 'some-key-error' }
    let(:validation_errors) { { param_key: param_error_value } }
    let(:organizer_class_name) { organizer_class ? organizer_class.name.split('::').last : 'N\A' }
    let(:action_class_name) { action_class ? action_class.name.split('::').last : 'N/A' }

    before do
      ctx.organized_by = organizer_class
      ctx[:invoked_action] = action_class
      ctx[:errors] = validation_errors
      error&.set_backtrace(backtrace)
    end

    describe 'error_info' do
      subject(:error_info_message) { instance.error_info.message }

      it 'sets default organizer message' do
        expect(error_info_message).to include(<<~TEXT.strip
          Organizer completed with unhandled errors:#{' '}
          {
            "param_key": "some-key-error"
          }
        TEXT
                                             )
      end

      context 'with custom message' do
        let(:message_override) { 'some-other-message' }

        it 'returns sets message with override' do
          expect(error_info_message).to eql(message_override)
        end
      end
    end

    describe '#message' do
      subject(:context_error_message) { instance.message.strip }

      context 'without error' do
        let(:error) { nil }

        it 'returns error message' do
          expect(context_error_message).to eql(<<~TEXT.strip
            Organizer: ApplicationOrganizer
              Action: ApplicationAction failed with errors:
              Validation Errors: {
              "param_key": "some-key-error"
            }
          TEXT
                                              )
        end
      end

      it 'returns context error summary' do
        expect(context_error_message).to eql(<<~TEXT.strip
          Organizer: ApplicationOrganizer
            Action: ApplicationAction failed with errors:
            Validation Errors: {
            "param_key": "some-key-error"
          }

          =========== SERVER ERROR FOUND: StandardError : some-error ===========

          FULL STACK TRACE
          some-backtrace-item

          ========================================================
        TEXT
                                            )
      end

      it 'includes organizer class name' do
        expect(context_error_message).to include("Organizer: #{organizer_class_name}")
      end

      it 'includes action class name' do
        expect(context_error_message).to include("Action: #{action_class_name} failed with errors:")
      end

      describe 'validation errors' do
        it 'prints param errors' do
          expect(context_error_message).to include(<<~TEXT
              Validation Errors: {
              "param_key": "#{param_error_value}"
            }
          TEXT
                                                  )
        end

        context 'without param errors' do
          let(:validation_errors) { {} }

          it 'prints empty param errors' do
            expect(context_error_message).to include(<<~TEXT
                Validation Errors: {
              }
            TEXT
                                                    )
          end
        end
      end

      context 'without organizer class' do
        let(:organizer_class) { nil }

        it 'excludes organizer name' do
          expect(context_error_message).to include("Organizer: N/A")
        end
      end

      context 'without action class' do
        let(:action_class) { nil }

        it 'excludes organizer name' do
          expect(context_error_message).to include("Action: N/A failed with errors:")
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
