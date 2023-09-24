# rubocop:disable Metrics/ModuleLength
module LightServiceExt
  RSpec.describe ApplicationContext do
    let(:input) { { key: 'some-value' } }
    let(:key) { :key }
    let(:value) { 'some-value' }

    subject(:ctx) { described_class.make_with_defaults(input) }

    describe '#record_raised_error' do
      let(:error_message) { 'Something went wrong' }
      let(:error) { RuntimeError.new('Something went wrong') }
      let(:backtrace) { ['some-backtrace-line'] }

      before do
        allow(subject).to receive(:organized_by) { ApplicationOrganizer }
        allow(ctx).to receive(:invoked_action) { ApplicationAction }

        error.set_backtrace(backtrace)
      end

      it 'records the error and adds it to the errors hash' do
        subject.record_raised_error(error)

        expect(subject.errors).to eql({ base: error_message })
        expect(subject.success?).to be_truthy

        internal_only = subject.internal_only
        expect(internal_only.keys).to eql([:error_info])

        error_info = internal_only[:error_info]
        expect(error_info.keys).to eql([:organizer, :action_name, :error])
        expect(error_info[:organizer]).to eql('ApplicationOrganizer')
        expect(error_info[:action_name]).to eql('ApplicationAction')

        raised_error_info = error_info[:error]
        expect(raised_error_info.keys).to eql([:type, :message, :backtrace])
        expect(raised_error_info[:type]).to eql(error.class.name)
        expect(raised_error_info[:message]).to eql(error_message)
        expect(raised_error_info[:backtrace]).to eql(error.backtrace)
      end

      it 'fails the operation and sets the error info' do
        subject.record_raised_error(error)

        expect(subject.success?).to be(true)
      end
    end

    describe '#organizer_name' do
      context 'with organizer' do
        before { allow(subject).to receive(:organized_by) { ApplicationOrganizer } }

        it 'returns the name of the organizer class' do
          expect(subject.organizer_name).to eq('ApplicationOrganizer')
        end
      end

      context 'without organizer' do
        before { allow(subject).to receive(:organized_by) { nil } }

        it 'returns nil' do
          expect(subject.organizer_name).to be(nil)
        end
      end
    end

    describe '#action_name' do
      context 'with invoked action' do
        before { allow(subject).to receive(:invoked_action) { ApplicationAction } }

        it 'returns the name of the organizer class' do
          expect(subject.action_name).to eq('ApplicationAction')
        end
      end

      context 'without invoked action' do
        before { allow(subject).to receive(:invoked_action) { nil } }

        it 'returns nil' do
          expect(subject.action_name).to be(nil)
        end
      end
    end

    describe '#formatted_errors' do
      before { allow(subject).to receive(:errors) { errors } }

      context 'with errors' do
        let(:errors) { { name: ['is required'], email: ['is invalid'] } }

        it 'returns a JSON string of the errors' do
          expect(subject.formatted_errors).to eq(JSON.pretty_generate(errors))
        end
      end

      context 'without errors' do
        let(:errors) { {} }

        it 'returns an empty JSON string if there are no errors' do
          expect(subject.formatted_errors).to eq(JSON.pretty_generate({}))
        end
      end

      context 'without errors' do
        let(:errors) { nil }

        it 'returns an empty JSON string if there are no errors' do
          expect(subject.formatted_errors).to eq(JSON.pretty_generate({}))
        end
      end
    end

    describe '#add_to_successful_actions' do
      it 'adds successful action name to context' do
        ctx.add_to_successful_actions(value)

        expect(ctx.successful_actions).to contain_exactly(value)
      end

      it 'preserves other successful action name' do
        ctx.add_to_successful_actions(value)

        ctx.add_to_successful_actions('other-value')

        expect(ctx.successful_actions).to contain_exactly(value, 'other-value')
      end
    end

    describe '#add_to_api_responses' do
      it 'adds last api response to context' do
        ctx.add_to_api_responses(value)

        expect(ctx.api_responses).to contain_exactly(value)
      end

      it 'preserves other api responses' do
        ctx.add_to_api_responses(value)

        ctx.add_to_api_responses('other-value')

        expect(ctx.api_responses).to contain_exactly(value, 'other-value')
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
                                                        current_api_response
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
            expect(ctx_with_defaults[:successful_actions]).to contain_exactly('some-action-class-name')
          end
        end

        context 'with api_responses set' do
          subject(:ctx_with_defaults) do
            described_class.make_with_defaults(input, api_responses: ['some-api-response'])
          end

          it 'allows for overrides' do
            expect(ctx_with_defaults[:api_responses]).to contain_exactly('some-api-response')
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
