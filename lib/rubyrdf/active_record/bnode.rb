if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class BNode < ::ActiveRecord::Base
        has_many :subject_statements, :as => :subject, :class_name => "RubyRDF::ActiveRecord::Statement"
        has_many :predicate_statements, :as => :predicate, :class_name => "RubyRDF::ActiveRecord::Statement"
        has_many :object_statements, :as => :object, :class_name => "RubyRDF::ActiveRecord::Statement"

        def to_rdf(bnodes)
          unless bnodes[:from_ar][self.id]
            o = Object.new
            bnodes[:from_ar][self.id] = o
            bnodes[:to_ar][o] = self.id
          end
          bnodes[:from_ar][self.id]
        end
      end
    end
  end
end
