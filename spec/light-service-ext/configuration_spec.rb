module LightServiceExt
  RSpec.describe Configuration do
    let(:error_class) { ArgumentError }
    let(:default_error_class) { EncodingError }

    subject(:config) { described_class.new }

    describe '#new' do
      context 'with non fatal error classes' do
        before do
          config.non_fatal_error_classes = [error_class]
        end

        describe '#non_fatal_error_classes' do
          it 'returns set fatal error classes' do
            expect(config.non_fatal_error_classes).to contain_exactly(error_class)
          end
        end
      end

      context 'with default non fatal errors' do
        before do
          described_class.configure do |config|
            config.default_non_fatal_error_classes = [default_error_class]
          end
        end

        describe '#default_non_fatal_error_classes' do
          it 'returns set non fatal error classes' do
            expect(config.default_non_fatal_error_classes).to contain_exactly(default_error_class)
          end
        end
      end

      context 'with default and non default non fatal errors' do
        before do
          described_class.configure do |config|
            config.non_fatal_error_classes = [error_class, default_error_class, nil]
            config.default_non_fatal_error_classes = [default_error_class]
          end
        end

        describe '#non_fatal_errors' do
          it 'returns non duplicate error classes' do
            expect(config.non_fatal_errors).to match_array([error_class, default_error_class].map(&:to_s))
          end
        end
      end

      describe '#allow_raise_on_failure' do
        it 'returns false' do
          expect(config.allow_raise_on_failure?).to be_truthy
        end

        context 'with allow raise on failure unset' do
          it 'returns true' do
            described_class.configure { |config| config.allow_raise_on_failure = false }

            expect(config.allow_raise_on_failure?).to be_falsey
          end
        end
      end
    end
  end
end

