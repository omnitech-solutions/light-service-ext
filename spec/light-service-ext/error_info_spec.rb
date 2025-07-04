RSpec.describe LightServiceExt::ErrorInfo do
  subject(:instance) { error_info_class.new(error, message: message_override, fatal: fatal) }

  let(:value) { "some-value" }
  let(:message_override) { nil }
  let(:message) { "some-error" }
  let(:fatal) { false }
  let(:backtrace) { ["some-backtrace-item"] }
  let(:error) { StandardError.new(message) }
  let(:error_info_class) { Class.new(described_class) }

  describe "#errors" do
    context "when error is a StandardError with no associated model or record" do
      let(:error) { StandardError.new(message) }

      it "returns a hash with a base error message" do
        expect(instance.errors).to eq({ base: message })
      end
    end

    context "with stubbed error" do
      before do
        allow(error).to receive(:set_backtrace)
        allow(error).to receive(:backtrace) { backtrace }
      end

      context "when error is associated with a model with validation errors" do
        let(:model) do
          double("Model", errors: double(:messages, messages: { field1: %w[error1 error2], field2: ["error3"] }))
        end
        let(:error) { double("Error", model: model, message: nil) }

        it "returns a hash with model validation errors" do
          expect(instance.errors).to eq({ base: { field1: %w[error1 error2], field2: ["error3"] } })
        end
      end

      context "when error is associated with a model with no validation errors" do
        let(:model) { double("Model", errors: double(:messages, messages: {})) }
        let(:error) { double("Error", model: model, message: nil) }

        it "returns an empty hash" do
          expect(instance.errors).to eq({ base: {} })
        end
      end

      context "when error is associated with a record with validation errors" do
        let(:record) do
          double("Record", errors: double(:messages, messages: { field1: %w[error1 error2], field2: ["error3"] }))
        end
        let(:error) { double("Error", record: record, message: nil) }

        it "returns a hash with record validation errors" do
          expect(instance.errors).to eq({ base: { field1: %w[error1 error2], field2: ["error3"] } })
        end
      end

      context "when error is associated with a record with no validation errors" do
        let(:record) { double("Record", errors: double(:messages, messages: {})) }
        let(:error) { double("Error", record: record, message: nil) }

        it "returns an empty hash" do
          expect(instance.errors).to eq({ base: {} })
        end
      end
    end
  end

  describe "#type" do
    it "returns error class name" do
      expect(instance.type).to eql(error.class.name)
    end
  end

  describe "#title" do
    it "returns error title with class name and message" do
      expect(instance.title).to eql("#{error.class.name} : #{message}")
    end
  end

  describe "message" do
    it "returns error message" do
      expect(instance.message).to eql(message)
    end

    context "with message override" do
      let(:message_override) { "some-other-message" }

      it "returns error message override" do
        expect(instance.message).to eql(message_override)
      end
    end
  end

  describe "#error" do
    it "returns original exception" do
      expect(instance.error).to eql(error)
    end
  end

  describe "#fatal_error?" do
    it "returns true" do
      expect(instance).to be_fatal_error
    end

    context "with non fatal error" do
      let(:error) { ArgumentError.new(message) }

      context "with fatal passed as arg" do
        let(:fatal) { true }

        it "returns true" do
          expect(instance.fatal_error?).to be_truthy
        end
      end

      context "with error set as non fatal" do
        before { LightServiceExt.configure { |c| c.non_fatal_error_classes = [ArgumentError] } }

        it "returns false" do
          expect(instance.fatal_error?).to be_falsey
        end

        context "with fatal passed as arg" do
          let(:fatal) { true }

          it "returns true" do
            expect(instance.fatal_error?).to be_truthy
          end
        end
      end
    end
  end

  describe "#error_summary" do
    before { error.set_backtrace(backtrace) }

    it "returns summary of error" do
      expect(instance.error_summary).to eql(<<~TEXT
        =========== SERVER ERROR FOUND: StandardError : some-error ===========

        FULL STACK TRACE
        some-backtrace-item

        ========================================================
      TEXT
                                           )
    end
  end

  describe "#to_h" do
    subject(:hash) { instance.to_h }

    before { error.set_backtrace(backtrace) }

    it "returns custom key value pairs" do
      expect(hash.keys).to match_array(%i[type message exception backtrace error errors fatal_error?])

      expect(hash[:type]).to eql(error.class.name)
      expect(hash[:message]).to eql(message)
      expect(hash[:exception]).to eql("#{error.class.name} : #{error.message}")
      expect(hash[:backtrace]).to eql(backtrace.join)
      expect(hash[:error]).to eql(error)
      expect(hash[:fatal_error?]).to be_truthy
      expect(hash[:errors]).to eql({ base: "some-error" })
    end

    context "with non fatal error" do
      let(:error) { ArgumentError.new(message) }

      before { LightServiceExt.configure { |c| c.non_fatal_error_classes = [ArgumentError] } }

      it "returns non fatal error" do
        expect(hash[:fatal_error?]).to be_falsey
      end
    end
  end
end
