# frozen_string_literal: true

require 'tmpdir'
require_relative '../../lib/generators/model_generator'

RSpec.describe ModelGenerator do
  around do |ex|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) { ex.run }
    end
  end

  it 'creates a model file from template' do
    generator = ModelGenerator.new
    generator.invoke(:model, ['user', 'name', 'email'])
    expect(File).to exist('user.rb')
    content = File.read('user.rb')
    expect(content).to include('class User')
    expect(content).to include('attr_accessor :name')
    expect(content).to include('attr_accessor :email')
  end
end

