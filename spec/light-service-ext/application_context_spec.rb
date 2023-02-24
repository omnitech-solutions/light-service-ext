# rubocop:disable Metrics/ModuleLength
module LightServiceExt
  RSpec.describe ApplicationContext do
    let(:input) { { key: 'some-value' } }
    let(:key) { :key }
    let(:value) { 'some-value' }

    subject(:ctx) { described_class.make_with_defaults(input) }

    describe '#add_to_successful_actions' do
      it 'adds successful action name to context' do
        ctx.add_to_successful_actions(value)

        expect(ctx.successful_actions).to match_array([value])
      end

      it 'preserves other successful action name' do
        ctx.add_to_successful_actions(value)

        ctx.add_to_successful_actions('other-value')

        expect(ctx.successful_actions).to match_array([value, 'other-value'])
      end
    end

    describe '#add_to_api_responses' do
      it 'adds last api response to context' do
        ctx.add_to_api_responses(value)

        expect(ctx.api_responses).to match_array([value])
      end

      it 'preserves other api responses' do
        ctx.add_to_api_responses(value)

        ctx.add_to_api_responses('other-value')

        expect(ctx.api_responses).to match_array([value, 'other-value'])
      end
    end

    describe '#add_last_failed_context' do
      it 'adds last failed context' do
        ctx.add_last_failed_context(value)

        expect(ctx.last_failed_context).to eql(value)
      end

      it 'updates older values' do
        ctx.add_last_failed_context(value)

        ctx.add_last_failed_context('other-value')

        expect(ctx.last_failed_context).to eql('other-value')
      end
    end

    describe '#add_status' do
      it 'adds current api response to context' do
        ctx.add_status(value)

        expect(ctx.status).to eql(value)
      end

      it 'updates older values' do
        ctx.add_status(value)

        ctx.add_status('other-value')

        expect(ctx.status).to eql('other-value')
      end
    end

    describe '#add_current_api_response' do
      it 'adds current api response to context' do
        ctx.add_current_api_response(value)

        expect(ctx.current_api_response).to eql(value)
      end

      it 'updates older values' do
        ctx.add_current_api_response(value)

        ctx.add_current_api_response('other-value')

        expect(ctx.current_api_response).to eql('other-value')
      end
    end

    describe '#add_invoked_action' do
      it 'adds last api response to context' do
        ctx.add_invoked_action(value)

        expect(ctx.invoked_action).to eql(value)
      end

      it 'updates older values' do
        ctx.add_invoked_action(value)

        ctx.add_invoked_action('other-value')

        expect(ctx.invoked_action).to eql('other-value')
      end
    end

    describe '#add_errors!' do
      before { allow(ctx).to receive(:fail_and_return!) }

      it 'fails the context' do
        ctx.add_errors!(key => value)

        expect(ctx).to have_received(:fail_and_return!)
      end

      it 'adds errors to context' do
        ctx.add_errors!(key => value)

        expect(ctx.errors).to eql(key => value)
      end

      it 'updates older values' do
        ctx.add_errors!(key => value)

        ctx.add_errors!(key => 'other-value')

        expect(ctx.errors).to eql(key => 'other-value')
      end

      it 'preserves other keys' do
        ctx.add_errors!(key => value)

        ctx.add_errors!(other_key: 'other-value')

        expect(ctx.errors).to include(key => value, :other_key => 'other-value')
      end
    end

    describe '#add_errors' do
      before { allow(ctx).to receive(:fail_and_return!) }

      it 'does not fail the context' do
        ctx.add_errors(key => value)

        expect(ctx).not_to have_received(:fail_and_return!)
      end

      it 'adds errors to context' do
        ctx.add_errors(key => value)

        expect(ctx.errors).to eql(key => value)
      end

      it 'updates older values' do
        ctx.add_errors(key => value)

        ctx.add_errors(key => 'other-value')

        expect(ctx.errors).to eql(key => 'other-value')
      end

      it 'preserves other keys' do
        ctx.add_errors(key => value)

        ctx.add_errors(other_key: 'other-value')

        expect(ctx.errors).to include(key => value, :other_key => 'other-value')
      end
    end

    describe '#add_params' do
      it 'adds params to context' do
        ctx.add_params(key => value)

        expect(ctx.params).to eql(key => value)
      end

      it 'updates older values' do
        ctx.add_params(key => value)

        ctx.add_params(key => 'other-value')

        expect(ctx.params).to eql(key => 'other-value')
      end

      it 'preserves other keys' do
        ctx.add_params(key => value)

        ctx.add_params(other_key: 'other-value')

        expect(ctx.params).to include(key => value, :other_key => 'other-value')
      end
    end

    describe '#add_internal_only' do
      it 'adds params to context' do
        ctx.add_internal_only(key => value)

        expect(ctx.internal_only).to include(key => value)
      end

      it 'updates older values' do
        ctx.add_internal_only(key => value)

        ctx.add_internal_only(key => 'other-value')

        expect(ctx.internal_only).to include(key => 'other-value')
      end

      it 'preserves other keys' do
        ctx.add_internal_only(key => value)

        ctx.add_internal_only(other_key: 'other-value')

        expect(ctx.internal_only).to include(key => value, :other_key => 'other-value')
      end
    end

    describe '.make_with_defaults' do
      let(:input) { { key: 'some-value' } }
      let(:overrides) { {} }

      subject(:ctx_with_defaults) { described_class.make_with_defaults(input, overrides) }

      context 'with non symbolized input keys' do
        let(:input) { { "key" => 'some-value' } }

        it 'symbolizes input attr keys' do
          expect(ctx_with_defaults[:input].keys).to include(:key)
        end
      end

      it 'returns context with default attrs' do
        expect(ctx_with_defaults.keys).to match_array(%i[
                                                        input
                                                        params
                                                        errors
                                                        status
                                                        successful_actions
                                                        allow_raise_on_failure
                                                        api_responses
                                                        internal_only
                                                        invoked_action
                                                        last_api_response
                                                        last_failed_context
                                                      ])

        expect(ctx_with_defaults[:input]).to eql(input)
      end

      describe 'overrideable attrs' do
        { errors: { key: 'some-error' },
          params: { key: 'value' },
          allow_raise_on_failure: false }.each_pair do |overridable_key, value|
          it "allows for default #{overridable_key.inspect} to be changed" do
            ctx_with_defaults = described_class.make_with_defaults(input, **{ overridable_key => value })
            expect(ctx_with_defaults[overridable_key]).to eql(value)
          end
        end

        context 'with successful_actions set' do
          subject(:ctx_with_defaults) do
            described_class.make_with_defaults(input, successful_actions: ['some-action-class-name'])
          end

          it 'allows for overrides' do
            expect(ctx_with_defaults[:successful_actions]).to match_array(['some-action-class-name'])
          end
        end

        context 'with api_responses set' do
          subject(:ctx_with_defaults) do
            described_class.make_with_defaults(input, api_responses: ['some-api-response'])
          end

          it 'allows for overrides' do
            expect(ctx_with_defaults[:api_responses]).to match_array(['some-api-response'])
          end
        end

        context 'with unexpected override' do
          subject(:ctx_with_defaults) { described_class.make_with_defaults(input, unknown_key: 'some-value') }

          it 'prevents successful_actions to change from default' do
            expect(ctx_with_defaults.keys).not_to include(:unknown_key)
          end
        end
      end
    end
  end
end
# rubocop:enable Metrics/ModuleLength
