# frozen_string_literal: true

require 'erb'
require 'thor'

class ModelGenerator < Thor
  desc 'model NAME [ATTRIBUTES...]', 'Generate a Ruby model file'
  def model(name, *attributes)
    template_path = File.expand_path('../templates/model.rb.erb', __dir__)
    template = File.read(template_path)
    class_name = name.split('_').map(&:capitalize).join
    rendered = ERB.new(template, trim_mode: '-').result(binding)
    File.write("#{name}.rb", rendered)
    say "Created #{name}.rb"
  end
end
