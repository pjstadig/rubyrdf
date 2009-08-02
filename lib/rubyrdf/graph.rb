module RubyRDF
  # The abstract base class for all graph implementations.  This defines the common interface for
  # graphs.  Implementations are free to extend this interface as long as the core, common
  # interface is implemented as specified here.
  class Graph
    # True if this graph is writable, false otherwise.
    def writable?; false end

    # Raises NotWritableError, if this graph is not writable, returns nil otherwise.
    def writable!; raise NotWritableError unless writable? end

    # Yields each statement to the block.
    def each(&b); raise NotImplementedError end

    # Performs a match against a statement fragment, where blank nodes that do not appear in the
    # graph, symbols, and nils are considered variables.
    #
    # Blank nodes and symbols will be bound on their first occurrence, and must match that binding
    # on subsequent occurrences.  For example,
    #   g.subgraph(:a, :a, :b)
    # will match
    #   <http://example.com/one> <http://example.com/one> <http://example.com/three> .
    # but will not match
    #   <http://example.com/one> <http://example.com/two> <http://example.com/three> .
    #
    # Any nils will be replaced with new blank nodes, so that
    #   g.subgraph(nil, nil, nil)
    # is equivalent to
    #   g.subgraph(RubyRDF::BlankNode.new, RubyRDF::BlankNode.new, RubyRDF::BlankNode.new)
    #
    # Returns graph of statements matching the fragment.
    # Returns an empty graph if +statement+ results in no matches, or if +statement+ is invalid.
    def subgraph(*statement); raise NotImplementedError end

    # True if the graph contains the statement, false otherwise.
    #
    # Raises InvalidStatementError, if +statement+ is invalid.
    def include?(*statement); raise NotImplementedError end

    # Returns the number of statements in the graph.
    def size; raise NotImplementedError end

    # True if the graph is empty, false otherwise.
    def empty?; size == 0 end

    # Exports the graph to +io+ in the specified +format+. Valid values for +format+ are:
    # * :ntriples
    # * :rdfxml
    def export(io, format = :ntriples); raise NotImplementedError end

    def unreify(node); raise NotImplementedError end

    # True if +bnode+ is contained in at least one statement in the graph, false otherwise.
    def known?(bnode); raise NotImplementedError end

    # True if +node+ is a variable with respect to this graph, false otherwise.
    #
    # +node+ is a variable if it is a Symbol, or if it is a BNode that is unknown to this graph.
    def variable?(node)
      node.is_a?(Symbol) || (bnode?(node) && !known?(node))
    end

    # Adds +statement+ to the graph.
    #
    # Returns true, if the statement was added, false if it was already in the graph.
    #
    # Raises NotWritableError, if the graph is not writable.
    # Raises InvalidStatementError, if +statement+ is invalid.
    def add(*statement); writable!; raise NotImplementedError end

    # Adds each statement from the +statements+ Enumerable object.
    #
    # Raises NotWritableError if the graph is not writable.
    # Raises InvalidStatementError, if any of the statements are invalid.
    def add_all(*statements)
      statements.each{|s| add(*s)}
    end

    # Deletes +statement+ from the graph.
    #
    # Returns true, if the statement was deleted, false if it was not in the graph.
    #
    # Raises NotWritableError, if the graph is not writable.
    # Raises InvalidStatementError, if +statement+ is invalid.
    def delete(*statement); writable!; raise NotImplementedError end

    # Deletes all statements from this graph.
    #
    # Returns true, if successful.
    #
    # Raises NotWritableError, if the graph is not writable.
    def delete_all
      writable!
      each{|s| delete(s)}
      true
    end

    def reify(*statement); writable!; raise NotImplementedError end

    # Adds +statements+ to the graph, replacing any occurrences of blank nodes with new blank nodes.
    #
    # Returns true, if successful.
    #
    # Raises NotWritableError, if the graph is not writable.
    # Raises InvalidStatementError, if any of the statements are invalid.
    def merge(*statements)
      writable!

      bnodes = {}
      statements.map{|st| st.to_statement}.each do |st|
        s, p, o = st.subject, st.predicate, st.object
        bnodes[s] ||= Object.new if bnode?(s)
        bnodes[o] ||= Object.new if bnode?(o)

        add(bnodes[s] || s, p, bnodes[o] || o)
      end
    end

    def uri?(node)
      node.is_a?(Addressable::URI)
    end

    def literal?(node)
      node.is_a?(PlainLiteral) || node.is_a?(TypedLiteral)
    end

    def bnode?(node)
      !uri?(node) && !literal?(node)
    end
  end
end
