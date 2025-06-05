module LightServiceExt
  RSpec.describe AllActionsCompleteAction do
    let(:allow_raise_on_failure) { false }
    let(:failure) { false }
    let(:errors) { {} }
    let(:input) { { key: "some-value" } }
    let(:overrides) { { errors: errors, allow_raise_on_failure: allow_raise_on_failure } }
    let(:ctx) { ApplicationContext.make_with_defaults(input, overrides) }

    subject(:executed_ctx) { described_class.execute(ctx) }

    context "with raising of errors allowed" do
      let(:allow_raise_on_failure) { true }

      it "does not raise error" do
        expect { executed_ctx }.not_to raise_error
      end
    end

    context "with failed context" do
      let(:errors) { { key: "must be filled" } }

      it "does not raise error" do
        expect { executed_ctx }.not_to raise_error

        expect(executed_ctx.keys).to include(:status)
      end

      context "with raising of errors allowed" do
        let(:allow_raise_on_failure) { true }

        it "raises custom context error" do
          expect { executed_ctx }.to raise_error ContextError
        end
      end
    end
  end
end
