if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class Statement < ::ActiveRecord::Base
        has_and_belongs_to_many :graphs, :class_name => "RubyRDF::ActiveRecord::Graph"

        belongs_to :subject, :polymorphic => true
        belongs_to :predicate, :polymorphic => true
        belongs_to :object, :polymorphic => true

        def self.create_by_rdf(statement, bnodes)
          t = statement.to_triple.map do |n|
            case n
            when ::RubyRDF::URINode
              URINode.find_or_create_by_rdf(n, bnodes)
            when ::RubyRDF::PlainLiteral
              PlainLiteral.find_or_create_by_rdf(n, bnodes)
            when ::RubyRDF::TypedLiteral
              TypedLiteral.find_or_create_by_rdf(n, bnodes)
            else
              BNode.find_or_create_by_rdf(n, bnodes)
            end
          end
          s = create
          s.subject_id = t[0].id
          s.subject_type = t[0].class.to_s
          s.predicate_id = t[1].id
          s.predicate_type = t[1].class.to_s
          s.object_id = t[2].id
          s.object_type = t[2].class.to_s
          s.save
          s
        end

        def self.find_by_rdf(statement, bnodes)
          t = statement.to_triple.map do |n|
            case n
            when ::RubyRDF::URINode
              URINode.find_by_rdf(n, bnodes)
            when ::RubyRDF::PlainLiteral
              PlainLiteral.find_by_rdf(n, bnodes)
            when ::RubyRDF::TypedLiteral
              TypedLiteral.find_by_rdf(n, bnodes)
            else
              BNode.find_by_rdf(n, bnodes)
            end
          end

          find(:first,
               :conditions => {
                 :subject_id => t[0].id,
                 :subject_type => t[0].class.to_s,
                 :predicate_id => t[1].id,
                 :predicate_type => t[1].class.to_s,
                 :object_id => t[2].id,
                 :object_type => t[2].class.to_s
               })
        end

        def to_rdf(bnodes)
          ::RubyRDF::Statement.new(subject.to_rdf(bnodes),
                                   predicate.to_rdf(bnodes),
                                   object.to_rdf(bnodes))
        end
      end
    end
  end
end
