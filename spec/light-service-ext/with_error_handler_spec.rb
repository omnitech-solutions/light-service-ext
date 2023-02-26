module LightServiceExt
  RSpec.describe WithErrorHandler do
    let(:implementor_class) do
      Class.new do
        extend WithErrorHandler
      end
    end

    let(:error_message) { 'some-error' }
    let(:ctx) { ApplicationContext.make_with_defaults }

    before { allow(LightServiceExt.config.logger).to receive(:error) }

    describe '.with_error_handler' do
      subject(:errors_handled_ctx) do
        implementor_class.with_error_handler(ctx: ctx, &results_ctx_proc)
      end

      context 'with non validation error' do
        let(:error) { ArgumentError.new(error_message) }
        let(:results_ctx_proc) { -> { raise error } }

        it 'logs errors' do
          expect { errors_handled_ctx }.to raise_error ArgumentError, error_message
          expect(LightServiceExt.config.logger).to have_received(:error)
        end
      end

      context 'with active record error' do
        let(:key) { :key }
        let(:key_error) { 'invalid' }
        let(:messages) { { key => [key_error] } }
        let(:error) { Rails::ActiveRecordError.new(error_message) }
        let(:errors) { double(:errors, messages: messages) }
        let(:model) { double(:model, errors: errors) }
        let(:results_ctx_proc) { -> { raise error } }

        context 'with error including model' do
          before { allow(error).to receive(:model) { model } }

          it 'adds model errors' do
            expect(errors_handled_ctx.failure?).to be_truthy
            expect(errors_handled_ctx.errors).to eql({ key => [key_error] })
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
