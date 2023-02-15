module LightServiceExt
  RSpec.describe ApplicationAction do
    FakeApplicationAction = Class.new(described_class) do
      executed do |context|
        value = context.dig(:input, :callback).call
        add_params(context, value: value)
      end
    end

    let(:organizer_class) do
      Class.new(ApplicationOrganizer) do
        def self.steps
          [FakeApplicationAction]
        end
      end
    end

    let(:value) { 'some-value' }
    let(:callback) { -> { value } }
    let(:input) { { callback: callback } }
    let(:ctx) do
      LightService::Testing::ContextFactory
        .make_from(organizer_class)
        .for(FakeApplicationAction)
        .with(callback: callback)
    end

    subject(:context) do
      FakeApplicationAction.execute(ctx)
    end

    it 'adds value returned by callback to params' do
      expect(context.keys).to include(:input, :errors, :params)

      expect(context[:params]).to eql({ value: value })
    end

    describe '.add_params' do
      let(:params) { { key: 'some-value' } }
      let(:ctx) { ApplicationContext.make_with_defaults }

      subject(:params_added) { described_class.add_params(ctx, **params) }

      it 'adds key value pairs to context params' do
        params_added

        expect(ctx[:params].keys).to include(:key)
      end
    end

    describe '.add_errors' do
      let(:ctx) { ApplicationContext.make_with_defaults }

      subject(:errors_added) { described_class.add_errors(ctx, **errors) }

      context 'without errors' do
        let(:errors) { {} }

        it 'does not raise error' do
          expect { errors_added }.not_to raise_error

          expect(ctx[:errors]).to be_empty
        end
      end

      context 'with errors' do
        let(:errors) { { key: 'not-found' } }

        it 'raises jump when failed error and adds errors to context' do
          expect { errors_added }.to raise_error UncaughtThrowError, 'uncaught throw :jump_when_failed'

          expect(ctx[:errors].keys).to include(:key)
        end
      end
    end
  end
end
