module LightServiceExt
  RSpec.describe ApplicationOrchestrator do
    describe '.call' do
      let(:orchestrator_class) do
        Class.new(described_class) do
          @organizer_action_class = Class.new do
            extend LightService::Action
            expects :input

            executed do |context|
              organizer_sub_context = LightService::Context.make(params: {})
              context.dig(:input, :organizer_action_proc)&.call(organizer_sub_context)

              # Store the modified organizer_sub_context for the block to use
              context[:organizer_result_context] = organizer_sub_context
              context # Return the original orchestrator context
            end
          end

          @orchestrator_action_class = Class.new do
            extend LightService::Action
            expects :input

            executed do |context|
              # The orchestrator_action_proc now expects to be called with a context
              # and modify that context.
              context.dig(:input, :orchestrator_action_proc).call(context)
              context # Ensure the context is returned
            end
          end

          class << self
            def organizer_steps
              [@organizer_action_class]
            end

            def steps
              [@orchestrator_action_class]
            end

            def call(input_context, &block)
              # Initialize params as an empty hash for the orchestrator context
              orchestrator_ctx = LightService::Context.make(input: input_context, params: {})

              # Process organizer steps. The result of organizer_action_class
              # will be stored in orchestrator_ctx[:organizer_result_context].
              process_each_organizer(orchestrator_ctx)

              # If a block is given, now is the time to apply its logic,
              # using the results from the organizer steps.
              if block_given? && orchestrator_ctx.key?(:organizer_result_context)
                # Call the block with the organizer's context and the orchestrator's context
                # The block is responsible for merging data into orchestrator_ctx
                yield(orchestrator_ctx[:organizer_result_context], orchestrator_ctx: orchestrator_ctx)
              end

              # Process orchestrator steps
              steps.each do |step_class|
                orchestrator_ctx = step_class.execute(orchestrator_ctx)
              end

              orchestrator_ctx.delete(:organizer_result_context) # Clean up temporary key
              orchestrator_ctx
            end

            private

            def process_each_organizer(orchestrator_ctx)
              organizer_steps.each do |step_class|
                orchestrator_ctx = step_class.execute(orchestrator_ctx)
              end
            end
          end
        end
      end

      let(:input) do
        {
          # This proc now modifies the context it receives
          organizer_action_proc: ->(context) { context[:params] = (context[:params] || {}).merge(x1: 'x1') },
          # This proc now modifies the context it receives
          orchestrator_action_proc: ->(context) { context[:params] = (context[:params] || {}).merge(x2: 'x2') }
        }
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
            # organizer_ctx is now the LightService::Context with params[:x1]
            orchestrator_ctx[:params] = (orchestrator_ctx[:params] || {}).merge(x3: organizer_ctx[:params][:x1])
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