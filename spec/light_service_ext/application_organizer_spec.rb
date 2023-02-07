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

    let(:input) { { :some_proc => proc {} } }

    it 'adds inputted data as input key value pair' do
      ctx = subject_class.call(input)

      expect(ctx.keys).to match_array(%i[errors input params])
      expect(ctx[:input]).to eql(input)
    end

    it 'calls underlying action' do
      expect do
        subject_class.call(:some_proc => proc { raise 'error' })
      end.to raise_error RuntimeError, 'error'
    end
  end
end
