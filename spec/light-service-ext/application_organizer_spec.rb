# frozen_string_literal: true

module LightServiceExt
  RSpec.describe ApplicationOrganizer do
    let(:subject_class) do
      Class.new(described_class) do
        class << self
          FakeAction = Class.new do
            extend LightService::Action

            expects :input

            executed do |context|
              context.dig(:input, :some_proc).call
            end
          end

          def steps
            [FakeAction]
          end
        end
      end
    end

    let(:input) { { some_proc: proc {} } }

    let(:ctx) { subject_class.call(input) }

    # rubocop:disable RSpec/AnyInstance
    before do
      allow_any_instance_of(ApplicationContext).to receive(:organized_by).and_return(described_class)
    end
    # rubocop:enable RSpec/AnyInstance

    it 'adds inputted data as input key value pair' do
      expect(ctx.keys).to include(:input)
      expect(ctx[:input]).to eql(input)
    end

    it 'calls underlying action' do
      error_proc = proc { raise 'error' }
      error_ctx = subject_class.call(some_proc: error_proc)
      allow(error_ctx).to receive(:organized_by).and_return(described_class)

      expect(error_ctx.errors).to be_present
      expect(error_ctx).to be_failure
      expect(error_ctx.status).to eql(Status::COMPLETE)
    end
  end
end
