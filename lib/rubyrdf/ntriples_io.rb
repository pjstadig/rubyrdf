module RubyRDF
  module NTriplesIO
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval <<-ENDL
      unless base.method_defined?(:import_without_ntriples)
        alias_method_chain :import, :ntriples
        alias_method_chain :export, :ntriples
      end
      ENDL
    end

    # Raised when there is a syntax error in an input NTriples file.
    class SyntaxError < Error; end

    module InstanceMethods
      def import_with_ntriples(io, format = :ntriples)
        if format == :ntriples
          Importer.new(io, self).import
        else
          import_without_ntriples(io, format)
        end
      end

      def export_with_ntriples(io, format = :ntriples)
        if format == :ntriples
          Exporter.new(io, self).export
        else
          export_without_ntriples(io, format)
        end
      end
    end
  end
end
