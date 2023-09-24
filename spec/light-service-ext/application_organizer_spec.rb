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

    before { allow_any_instance_of(ApplicationContext).to receive(:organized_by) { ApplicationOrganizer } }


    it 'adds inputted data as input key value pair' do
      ctx = subject_class.call(input)

      expect(ctx.keys).to include(:input)
      expect(ctx[:input]).to eql(input)
    end

    it 'calls underlying action' do
      ctx = subject_class.call(some_proc: proc { raise 'error' })

      expect(ctx.errors).to be_present
      expect(ctx).to be_failure
      expect(ctx.status).to eql(Status::COMPLETE)
    end
  end
end
