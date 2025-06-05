# frozen_string_literal: true

require 'fileutils'
require 'active_support/core_ext/string/inflections'

module LightServiceExt
  module Generators
    class Base
      attr_reader :resource, :attributes, :output_root, :force

      def initialize(resource:, attributes:, output_root: '.', force: false)
        @resource = resource.to_s
        @attributes = Array(attributes).map(&:to_s)
        @output_root = output_root
        @force = force
      end

      private

      def write_file(path, content)
        return if File.exist?(path) && !force

        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, content)
      end

      def class_name_prefix
        resource.camelize
      end

      def resource_plural
        resource.pluralize
      end
    end
  end
end
