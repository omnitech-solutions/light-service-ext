# frozen_string_literal: true

require 'tmpdir'

module LightServiceExt
  RSpec.describe Generators::CreateOrganizerGenerator do
    let(:dto_class) do
      Class.new(LightServiceExt::ApplicationContract) do
        params do
          required(:name).filled(:string)
        end
      end
    end

    around do |example|
      Dir.mktmpdir do |dir|
        @tmp = dir
        example.run
      end
    end

    it 'creates organizer file' do
      generator = described_class.new(resource: 'user', dto_class: dto_class, output_root: @tmp, force: true)
      generator.generate

      file_path = File.join(@tmp, 'services', 'user', 'create_user_organizer.rb')
      expect(File).to exist(file_path)
      content = File.read(file_path)
      expect(content).to include('CreateUserOrganizer')
      expect(content).to include('UserValidatorAction')
    end
  end
end
