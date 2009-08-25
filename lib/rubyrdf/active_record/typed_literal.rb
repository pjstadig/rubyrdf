if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class TypedLiteral < ::ActiveRecord::Base
        def self.find_or_create_by_rdf(typed_literal, bnodes)
          n = find_by_rdf(typed_literal, bnodes)
          unless n
            n = create(:lexical_form => typed_literal.lexical_form,
                       :datatype_uri => typed_literal.datatype_uri.uri)
          end
          n
        end

        def self.find_by_rdf(typed_literal, bnodes)
          find(:first,
               :conditions => {
                 :lexical_form => typed_literal.lexical_form,
                 :datatype_uri => typed_literal.datatype_uri.uri
               })
        end

        def to_rdf(bnodes)
          ::RubyRDF::TypedLiteral.new(lexical_form, datatype_uri)
        end
      end
    end
  end
end
