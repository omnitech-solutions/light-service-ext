# frozen_string_literal: true

require 'tmpdir'

module LightServiceExt
  RSpec.describe Generators::CreateOrganizerGenerator do
    let(:attributes) { %w[name email] }

    around do |example|
      Dir.mktmpdir do |dir|
        @tmp = dir
        example.run
      end
    end

    it 'creates organizer file' do
      generator = described_class.new(resource: 'user', attributes: attributes, output_root: @tmp, force: true)
      generator.generate

      file_path = File.join(@tmp, 'services', 'user', 'create_user_organizer.rb')
      expect(File).to exist(file_path)
      content = File.read(file_path)
      expect(content).to include('CreateUserOrganizer')
      expect(content).to include('UserValidatorAction')
    end
  end
end
