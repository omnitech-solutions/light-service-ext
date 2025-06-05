# frozen_string_literal: true

require 'erb'
require 'thor'

class ModelGenerator < Thor
  desc 'model NAME [ATTRIBUTES...]', 'Generate a Ruby model file'
  def model(name, *attributes)
    template_path = File.expand_path('../templates/model.rb.erb', __dir__)
    class_name = name.split('_').map(&:capitalize).join
    erb = ERB.new(File.read(template_path), trim_mode: '-')
    content = erb.result_with_hash(class_name: class_name, attributes: attributes)
    File.write("#{name}.rb", content)
    say "Created #{name}.rb"
  end
end
