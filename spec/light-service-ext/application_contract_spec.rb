module LightServiceExt
  RSpec.describe ApplicationContract do
    let(:contract_class) do
      Class.new(ApplicationContract) do
        params do
          required(:email).maybe(:string)
        end

        rule(:email).validate(:email)
      end
    end

    describe '.keys' do
      it 'returns schema rule keys' do
        expect(contract_class.keys).to match_array([:email])
      end
    end

    describe '.register_macro' do
      describe ':email' do
        let(:email) { nil }
        let(:params) { { email: email } }

        subject(:result) { contract_class.new.call(params) }

        context 'with valid email' do
          let(:email) { 'email@domain.com' }

          it 'returns success' do
            expect(result).to be_success
          end
        end

        context 'with invalid email' do
          let(:email) { 'emaildomain.com' }

          it 'returns failure' do
            expect(result).to be_failure

            errors = result.errors.to_h
            expect(errors.keys).to match_array([:email])

            error_messages = errors[:email]
            expect(error_messages).to match_array(["must be a valid email"])
          end
        end
      end
    end
  end
end
