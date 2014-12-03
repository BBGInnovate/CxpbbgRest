module CxpbbgRest
  module Generators
    class Base < Rails::Generators::NamedBase
      def self.source_root
        @_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'cxpbbg_rest', generator_name, 'templates'))
      end
    end
  end
end
