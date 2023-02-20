module LightServiceExt
  RSpec.describe ApplicationContext do
    let(:input) { { key: 'some-value' } }
    let(:key) { :key }
    let(:value) { 'some-value' }
    subject(:ctx) { described_class.make_with_defaults(input) }

    describe '#add_errors!' do
      before(:each) { allow(ctx).to receive(:fail_and_return!) }

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

        expect(ctx.errors).to include(key => value, other_key: 'other-value')
      end
    end

    describe '#add_errors' do
      before(:each) { allow(ctx).to receive(:fail_and_return!) }

      it 'does not fail the context' do
        ctx.add_errors(key => value)

        expect(ctx).to_not have_received(:fail_and_return!)
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

        expect(ctx.errors).to include(key => value, other_key: 'other-value')
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

        expect(ctx.params).to include(key => value, other_key: 'other-value')
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
        expect(ctx_with_defaults.keys).to match_array(%i[input
                                                         errors
                                                         params
                                                         successful_actions
                                                         api_responses
                                                         allow_raise_on_failure])

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

          it 'prevents successful_actions to change from default' do
            expect(ctx_with_defaults[:successful_actions]).to be_empty
          end
        end

        context 'with api_responses set' do
          subject(:ctx_with_defaults) do
            described_class.make_with_defaults(input, api_responses: ['some-api-response'])
          end

          it 'prevents successful_actions to change from default' do
            expect(ctx_with_defaults[:api_responses]).to be_empty
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
