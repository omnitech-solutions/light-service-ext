module LightServiceExt
  RSpec.describe WithErrorHandler do
    let(:implementor_class) do
      Class.new do
        extend WithErrorHandler
      end
    end

    let(:ctx) { ApplicationContext.make_with_defaults }

    before do
      allow(ctx).to receive_messages(organized_by: ApplicationOrganizer, invoked_action: ApplicationAction)
    end

    describe '.with_error_handler' do
      let(:error_message) { 'some-error' }
      let(:error) { RuntimeError.new(error_message) }
      let(:results_ctx_proc) { -> { raise error } }

      subject(:raised_error_handled_ctx) do
        implementor_class.with_error_handler(ctx: ctx, &results_ctx_proc)
      end

      before { allow(ctx).to receive(:record_raised_error) }

      it 'fails context and records error' do
        expect(raised_error_handled_ctx.failure?).to be_truthy
        expect(raised_error_handled_ctx).to have_received(:record_raised_error).with(error)
        expect(raised_error_handled_ctx.status).to eql(Status::COMPLETE)
      end
    end
  end
end
