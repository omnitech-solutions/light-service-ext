# frozen_string_literal: true

require 'thor'
require 'erb'
require 'fileutils'

class ModelGenerator < Thor
  desc 'model NAME [ATTRIBUTES...]', 'Generates a model file with given attributes'
  def model(name, *attributes)
    class_name = name.split('_').collect(&:capitalize).join
    template_path = File.expand_path('../../templates/model.rb.erb', __FILE__)
    output_path = File.join(Dir.pwd, "#{name}.rb")

    template = ERB.new(File.read(template_path), trim_mode: '-')
    content = template.result_with_hash(class_name: class_name, attributes: attributes)

    File.write(output_path, content)
    puts "Created #{output_path}"
  end
end
