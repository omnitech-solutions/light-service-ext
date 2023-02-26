# frozen_string_literal: true

module LightServiceExt
  RSpec.describe RecordActions do
    describe '.call' do
      let(:input) { {} }
      let(:action_name) { 'some-action-name' }
      let(:current_api_response) { nil }
      let(:invoked_action) { nil }
      let(:status) { nil }
      let(:errors) { {} }
      let(:overrides) { { errors: errors } }
      let(:ctx) { ApplicationContext.make_with_defaults(input, overrides) }
      let(:result_ctx_overrides) do
        { status: status, errors: errors, invoked_action: invoked_action, current_api_response: current_api_response }
      end
      let(:result_ctx) { ApplicationContext.make_with_defaults(input, result_ctx_overrides) }
      let(:proc) { -> { result_ctx } }

      subject(:called_ctx) { described_class.call(ctx, &proc) }

      it 'returns expected context' do
        expect(called_ctx.success?).to be_truthy
        expect(called_ctx.successful_actions).to match_array([])
        expect(called_ctx.api_responses).to match_array([])
        expect(called_ctx.status).to eql(Status::INCOMPLETE)
        expect(called_ctx[:last_failed_context]).to be_nil
      end

      context 'with api response attrs' do
        let(:invoked_action) { class_double(ApplicationAction, name: action_name) }
        let(:current_api_response) { 'some-api-response' }

        it 'adds api_response as last api response' do
          expect(called_ctx.success?).to be_truthy
          expect(called_ctx.successful_actions).to match_array([action_name])
          expect(called_ctx.api_responses).to match_array([current_api_response])
          expect(called_ctx.status).to eql(Status::INCOMPLETE)
          expect(called_ctx[:last_failed_context]).to be_nil
        end

        context 'with completed status' do
          let(:status) { :all_steps_complete }

          it 'adds errors and last failed context' do
            expect(called_ctx.success?).to be_truthy
            expect(called_ctx.successful_actions).to be_empty
            expect(called_ctx.api_responses).to be_empty
            expect(called_ctx.status).to eql(status)
            expect(called_ctx[:last_failed_context]).to be_nil
          end

          context 'with errors' do
            let(:errors) { { base: 'some-message' } }

            it 'adds last failed context and fails the context' do
              expect(called_ctx.success?).to be_falsey
              expect(called_ctx.successful_actions).to be_empty
              expect(called_ctx.api_responses).to be_empty
              expect(called_ctx.status).to eql(status)
              expect(called_ctx[:last_failed_context]).to be_present
            end
          end
        end
      end
    end
  end
end
