module LightServiceExt
  RSpec.describe AroundActionExecuteExtension do
    let(:fake_action) do
      Class.new do
        prepend AroundActionExecuteExtension

        def execute(_ctx)
          fake_resultant_ctx # HACK: to allow us to control returned value from prepended execute method
        end

        def fake_resultant_ctx; end
      end.new
    end

    describe '#execute' do
      let(:input) { { key: 'some-value' } }
      let(:orig_ctx) { ApplicationContext.make_with_defaults }
      let(:errors) { {} }
      let(:frozen_resultant_ctx) do
        ApplicationContext.make_with_defaults.merge({ key: 'some-value', errors: errors }).freeze
      end

      subject(:executed_ctx) { fake_action.execute(orig_ctx) }

      before do
        allow(fake_action).to receive(:fake_resultant_ctx) { frozen_resultant_ctx }
      end

      it 'returns unmodified resultant context' do
        expect(executed_ctx).to eql(frozen_resultant_ctx)
      end

      it 'calls underlying prepended execute method' do
        executed_ctx

        expect(fake_action).to have_received(:fake_resultant_ctx)
      end

      it 'merges key value pairs from underlying execute to original context' do
        executed_ctx

        expect(orig_ctx.keys).to include(:key)
      end

      context 'with resultant ctx with errors' do
        let(:errors) { { key: 'must be filled' } }

        it 'fails original context' do
          executed_ctx

          expect(orig_ctx.failure?).to be_truthy
        end
      end
    end
  end
end
