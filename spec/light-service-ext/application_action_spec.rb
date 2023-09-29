module LightServiceExt
  RSpec.describe ApplicationAction do
    let(:fake_action) do
      Class.new(described_class) do
        executed do |context|
          value = context.dig(:input, :callback).call
          context.add_params(value: value)
          context.add_errors!(value: value)
        end
      end
    end

    let(:organizer_class) do
      Class.new(ApplicationOrganizer) do end
    end

    let(:value) { 'some-value' }
    let(:callback) { -> { value } }
    let(:input) { { callback: callback } }
    let(:ctx) do
      LightService::Testing::ContextFactory
        .make_from(organizer_class)
        .for(fake_action)
        .with(callback: callback)
    end

    subject(:executed_ctx) { fake_action.execute(ctx) }

    before do
      allow(organizer_class).to receive(:steps) { [fake_action] }
    end

    it 'adds value returned by callback to params' do
      expect(executed_ctx.keys).to include(:input, :errors, :params)

      expect(executed_ctx[:params]).to eql({ value: value })
    end

    describe 'lifecycle callbacks' do
      before do
        allow(fake_action.before_execute_block).to receive(:call)
        allow(fake_action.after_execute_block).to receive(:call)
        allow(fake_action.after_success_block).to receive(:call)
        allow(fake_action.after_failure_block).to receive(:call)
      end

      it 'calls appropriate lifecycle callbacks' do
        executed_ctx

        expect(fake_action.before_execute_block).to have_received(:call).with(kind_of(ApplicationContext)).at_least(:once)
        expect(fake_action.after_execute_block).to have_received(:call).with(kind_of(ApplicationContext))
        expect(fake_action.after_success_block).not_to have_received(:call).with(kind_of(ApplicationContext))
        expect(fake_action.after_failure_block).to have_received(:call).at_least(:once)
      end

      context 'with failure' do
        before do
          allow_any_instance_of(ApplicationContext).to receive(:errors) { {} }
          allow_any_instance_of(ApplicationContext).to receive(:success?) { true }
        end

        it 'calls appropriate lifecycle callbacks' do
          executed_ctx

          expect(fake_action.before_execute_block).to have_received(:call).with(kind_of(ApplicationContext)).at_least(:once)
          expect(fake_action.after_execute_block).to have_received(:call).with(kind_of(ApplicationContext)).at_least(:once)
          expect(fake_action.after_success_block).to have_received(:call).with(kind_of(ApplicationContext))
          expect(fake_action.after_failure_block).to_not have_received(:call)
        end
      end
    end
  end
end
