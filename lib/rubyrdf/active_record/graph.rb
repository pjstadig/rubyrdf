if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class Graph < ::ActiveRecord::Base
        has_and_belongs_to_many :statements, :class_name => "RubyRDF::ActiveRecord::Statement", :after_remove => :cleanup_statement

        def cleanup_statement(statement)
          if statement.graphs.empty?
            subject = statement.subject
            predicate = statement.predicate
            object = statement.object
            statement.destroy

            cleanup_node(subject)
            cleanup_node(predicate)
            cleanup_node(object)
          end
        end

        def cleanup_node(node)
          if node.subject_statements.empty? &&
              node.predicate_statements.empty? &&
              node.object_statements.empty?
            node.destroy
          end
        end
      end
    end
  end
end
