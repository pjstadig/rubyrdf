if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class PlainLiteral < ::ActiveRecord::Base
        def self.find_or_create_by_rdf(plain_literal, bnodes)
          n = find_by_rdf(plain_literal, bnodes)
          unless n
            n = create(:lexical_form => plain_literal.lexical_form,
                       :language_tag => plain_literal.language_tag)
          end
          n
        end

        def self.find_by_rdf(plain_literal, bnodes)
          find(:first,
               :conditions => {
                 :lexical_form => plain_literal.lexical_form,
                 :language_tag => plain_literal.language_tag
               })
        end

        def to_rdf(bnodes)
          ::RubyRDF::PlainLiteral.new(lexical_form, language_tag)
        end
      end
    end
  end
end
