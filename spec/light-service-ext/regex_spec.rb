RSpec.describe LightServiceExt::Regex do
  describe ".match?" do
    subject(:matched) { described_class.match?(type, value) }

    let(:value) { nil }
    let(:type) { nil }

    describe ":email" do
      let(:type) { :email }

      context "with valid email" do
        let(:value) { "email@domain.com" }

        it "returns true" do
          expect(matched).to be_truthy
        end
      end

      context "with invalid email" do
        let(:value) { "emaild.g" }

        it "returns false" do
          expect(matched).to be_falsey
        end
      end
    end
  end
end
