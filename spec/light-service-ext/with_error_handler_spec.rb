module LightServiceExt
  RSpec.describe WithErrorHandler do
    unless defined? Rails
      module Rails
      end
    end

    unless defined? Rails::ActiveRecordError
      module Rails
        class ActiveRecordError < StandardError
          def model; end
        end
      end
    end

    let(:implementor_class) do
      Class.new do
        extend WithErrorHandler
      end
    end

    let(:key) { :key }
    let(:key_error) { 'invalid' }
    let(:messages) { { key => [key_error] } }
    let(:error_message) { 'some-error' }
    let(:errors) { OpenStruct.new(messages: messages) }
    let(:model) { OpenStruct.new(errors: errors) }
    let(:results_ctx_proc) { -> { ApplicationContext.make_with_defaults } }
    let(:ctx) { ApplicationContext.make_with_defaults }
    let(:error) { Rails::ActiveRecordError.new(error_message) }

    before { allow(LightServiceExt.config.logger).to receive(:error) }

    describe '.with_error_handler' do
      subject(:errors_handled_ctx) do
        implementor_class.with_error_handler(ctx: ctx, &results_ctx_proc)
      end

      context 'with active record error' do
        let(:results_ctx_proc) { -> { raise error } }

        context 'with error including model' do
          before { allow(error).to receive(:model) { model } }

          it 'adds model errors' do
            expect(errors_handled_ctx.failure?).to be_truthy
            expect(errors_handled_ctx.errors).to eql({ key => key_error })
            expect(errors_handled_ctx.internal_only[:error_info]).to be_an_instance_of(ErrorInfo)
            expect(LightServiceExt.config.logger).to have_received(:error)
          end
        end

        it 'adds errors to context' do
          expect(errors_handled_ctx.failure?).to be_truthy
          expect(errors_handled_ctx.errors).to eql({ base: error_message })
          expect(errors_handled_ctx.internal_only[:error_info]).to be_an_instance_of(ErrorInfo)
          expect(LightServiceExt.config.logger).to have_received(:error)
        end
      end
    end
  end
end
