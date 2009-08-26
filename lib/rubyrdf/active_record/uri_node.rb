if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class URINode < ::ActiveRecord::Base
        has_many :subject_statements, :as => :subject, :class_name => "RubyRDF::ActiveRecord::Statement"
        has_many :predicate_statements, :as => :predicate, :class_name => "RubyRDF::ActiveRecord::Statement"
        has_many :object_statements, :as => :object, :class_name => "RubyRDF::ActiveRecord::Statement"

        def to_rdf(bnodes)
          ::RubyRDF::URINode.new(uri)
        end
      end
    end
  end
end
