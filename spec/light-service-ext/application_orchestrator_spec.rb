module LightServiceExt
  RSpec.describe ApplicationOrchestrator do
    describe '.call' do
      let(:orchestrator_class) do
        FakeOrganizer = Class.new(ApplicationOrganizer) do
          class << self
            FakeOrganizerAction = Class.new do
              extend LightService::Action

              expects :input

              executed do |context|
                context.dig(:input, :organizer_action_proc).call(context)
              end
            end

            def steps
              [FakeOrganizerAction]
            end
          end
        end

        Class.new(described_class) do
          class << self
            FakeOrchestratorAction = Class.new do
              extend LightService::Action

              expects :input

              executed do |context|
                context.dig(:input, :orchestrator_action_proc).call(context)
              end
            end

            def organizer_steps
              [FakeOrganizer]
            end

            def steps
              [FakeOrchestratorAction]
            end
          end
        end
      end

      let(:input) do
        { organizer_action_proc: ->(context) { context.add_params(x1: 'x1') },
          orchestrator_action_proc: ->(context) { context.add_params(x2: 'x2') } }
      end

      it 'adds orchestrator params without organizer params' do
        ctx = orchestrator_class.call(input)

        expect(ctx.keys).to include(:input)
        expect(ctx[:input]).to eql(input)
        expect(ctx[:params]).to eql(x2: 'x2')
      end

      context 'with each organizer block' do
        let(:organizer_block) do
          lambda { |organizer_ctx, orchestrator_ctx:|
            orchestrator_ctx.add_params(x3: organizer_ctx.params[:x1])
          }
        end

        it 'adds organizer param to orchestrator' do
          orchestrator_ctx = orchestrator_class.call(input, &organizer_block)

          expect(orchestrator_ctx.keys).to include(:input)
          expect(orchestrator_ctx[:input]).to eql(input)
          expect(orchestrator_ctx[:params]).to include(x2: 'x2', x3: 'x1')
        end
      end
    end
  end
end
