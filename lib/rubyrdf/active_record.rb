if defined?(ActiveRecord)
  require 'rubyrdf/graph'

  module RubyRDF
    class ActiveRecord < RubyRDF::Graph
      def initialize(id = nil)
        @graph = id ? Graph.find(id) : Graph.create
        @bnodes = {
          :from_ar => {},
          :to_ar => {}
        }
      end

      def writable?; true end

      def each
        @graph.statements.each{|s| yield s.to_rdf(@bnodes)}
      end

      def add(*statement)
        unless include?(*statement)
          s = Statement.create_by_rdf(statement.to_statement, @bnodes)
          @graph.statements << s
          @graph.save
        end
      end

      def delete(*statement)
        s = @graph.statements.find_by_rdf(statement.to_statement, @bnodes)
        if s
          @graph.statements.delete(s)
          @graph.save
        end
      end

      def include?(*statement)
        @graph.statements.find_by_rdf(statement.to_statement, @bnodes)
      end
    end
  end
end
