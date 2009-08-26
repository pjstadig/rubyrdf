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

      def match(*triple)
        triple = triple.to_triple.map{|n| find_node(n)}
        conditions = {}
        if triple[0]
          conditions[:subject_id] = triple[0].id
          conditions[:subject_type] = triple[0].class.to_s
        end

        if triple[1]
          conditions[:predicate_id] = triple[1].id
          conditions[:predicate_type] = triple[1].class.to_s
        end

        if triple[2]
          conditions[:object_id] = triple[2].id
          conditions[:object_type] = triple[2].class.to_s
        end

        stmts = @graph.statements.find(:all,
                                       :conditions => conditions).map{|s| to_rdf(s)}
        if block_given?
          stmts.each{|s| yield s}
        else
          RubyRDF::MemoryGraph.new(*stmts)
        end
      end

      def add(*statement)
        s = find_or_create_statement(statement.to_statement)
        @graph.statements << s unless @graph.statements.include?(s)
        true
      end

      def delete(*statement)
        s = find_statement(statement.to_statement)
        if s && @graph.statements.include?(s)
          @graph.statements.delete(s)
          @graph.save
        end
      end

      def include?(*statement)
        s = find_statement(statement.to_statement)
        s && @graph.statements.include?(s)
      end

      def known?(node)
        RubyRDF.bnode?(node) && @bnodes[:to_ar][node]
      end

      def size
        @graph.statements.size
      end

      private
      def find_statement(statement)
        triple = statement.to_triple.map{|n| find_node(n)}
        return nil if triple.any?{|n| n.nil?}
        Statement.find(:first,
                       :conditions => ["subject_id = ? and " +
                                       "subject_type = ? and " +
                                       "predicate_id = ? and " +
                                       "predicate_type = ? and " +
                                       "object_id = ? and " +
                                       "object_type = ?",
                                       triple[0].id,
                                       triple[0].class.to_s,
                                       triple[1].id,
                                       triple[1].class.to_s,
                                       triple[2].id,
                                       triple[2].class.to_s])
      end

      def find_or_create_statement(statement)
        s = find_statement(statement)
        unless s
          triple = statement.to_statement.to_triple.map{|n| find_or_create_node(n)}
          s = Statement.create(:subject_id => triple[0].id,
                               :subject_type => triple[0].class.to_s,
                               :predicate_id => triple[1].id,
                               :predicate_type => triple[1].class.to_s,
                               :object_id => triple[2].id,
                               :object_type => triple[2].class.to_s)
        end
        s
      end

      def find_node(node)
        case node
        when ::RubyRDF::URINode
          URINode.find_by_uri(node.uri)
        when ::RubyRDF::PlainLiteral
          PlainLiteral.find_by_lexical_form_and_language_tag(node.lexical_form, node.language_tag)
        when ::RubyRDF::TypedLiteral
          TypedLiteral.find_by_lexical_form_and_datatype_uri(node.lexical_form, node.datatype_uri.uri)
        when NilClass
          nil
        else
          BNode.find_by_id(@bnodes[:to_ar][node]) if @bnodes[:to_ar][node]
        end
      end

      def find_or_create_node(node)
        case node
        when ::RubyRDF::URINode
          URINode.find_or_create_by_uri(node.uri)
        when ::RubyRDF::PlainLiteral
          PlainLiteral.find_or_create_by_lexical_form_and_language_tag(node.lexical_form, node.language_tag)
        when ::RubyRDF::TypedLiteral
          TypedLiteral.find_or_create_by_lexical_form_and_datatype_uri(node.lexical_form, node.datatype_uri.uri)
        else
          unless @bnodes[:to_ar][node]
            bn = BNode.create
            @bnodes[:to_ar][node] = bn.id
            @bnodes[:from_ar][bn.id] = node
          end
          BNode.find_by_id(@bnodes[:to_ar][node])
        end
      end

      def to_rdf(statement)
        ::RubyRDF::Statement.new(statement.subject.to_rdf(@bnodes),
                                 statement.predicate.to_rdf(@bnodes),
                                 statement.object.to_rdf(@bnodes))
      end
    end
  end
end
