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

      describe '#on_raised_error' do
        it 'returns a proc' do
          expect(config.on_raised_error).to be_a(Proc)
        end

        context 'with configured callback' do
          let(:error) { ArgumentError.new('some-error') }
          let(:callback) { proc { |_ctx, _error| } }

          before do
            described_class.configure { |config| config.on_raised_error = callback }
          end

          after(:each) do
            described_class.configure { |config| config.on_raised_error = proc {|_ctx, _error|} }
          end


          it 'returns set proc' do
            ctx = ApplicationContext.make_with_defaults
            ctx.record_raised_error(error)

            expect(described_class.config.on_raised_error).to eql(callback)
          end
        end
      end

      describe '#fatal_error?' do
        context 'with error class configured as non fatal' do
          before { config.non_fatal_error_classes = [ArgumentError] }

          it 'returns false for non fatal error' do
            expect(config.fatal_error?(ArgumentError.new('x'))).to be_falsey
          end
        end

        it 'returns true for unconfigured error class' do
          expect(config.fatal_error?(RuntimeError.new('y'))).to be_truthy
        end
      end

      describe '#non_fatal_error?' do
        before { config.non_fatal_error_classes = [ArgumentError] }

        it 'returns true when error is configured as non fatal' do
          expect(config.non_fatal_error?(ArgumentError.new('x'))).to be_truthy
        end

        it 'returns false for unconfigured error class' do
          expect(config.non_fatal_error?(RuntimeError.new('y'))).to be_falsey
        end
      end
    end
  end
end

