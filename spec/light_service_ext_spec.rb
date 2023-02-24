# frozen_string_literal: true

RSpec.describe LightServiceExt do
  it "has a version number" do
    expect(described_class::VERSION).not_to be_nil
  end

  describe '.configure' do
    subject(:config) { described_class.configuration }

    let(:error_class) { ArgumentError }
    let(:default_error_class) { EncodingError }

    after do
      # rubocop:disable Style/ClassVars
      described_class.class_variable_set(:@@configuration, described_class::Configuration.new)
      # rubocop:enable Style/ClassVars
    end

    context 'with non fatal error classes' do
      before do
        described_class.configure do |config|
          config.non_fatal_error_classes = [error_class]
        end
      end

      describe '#non_fatal_error_classes' do
        it 'returns set fatal error classes' do
          expect(config.non_fatal_error_classes).to match_array([error_class])
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
          expect(config.default_non_fatal_error_classes).to match_array([default_error_class])
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
      context 'with allow raise on failure unset' do
        it 'returns true' do
          described_class.configure { |config| config.allow_raise_on_failure = false }

          expect(config.allow_raise_on_failure?).to be_falsey
        end
      end
    end
  end
end
