module LightServiceExt
  RSpec.describe ApplicationAction do
    FakeApplicationAction = Class.new(described_class) do
      executed do |context|
        value = context.dig(:input, :callback).call
        context.add_params(value: value)
        context.add_errors!(value: value)
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
  end
end
