module RubyRDF
  # The abstract base class for all graph implementations.  This defines the common interface for
  # graphs.  Implementations are free to extend this interface as long as the core, common
  # interface is implemented as specified here.
  #--
  # TODO transaction support
  class Graph
    include Enumerable

    # Yields each statement to the given block
    def each; raise NotImplementedError end

    # Adds +statement+ to the graph.
    #
    # Returns true, if the statement was added, false if it was already in the graph.
    #
    # Raises NotWritableError, if the graph is not writable.
    # Raises InvalidStatementError, if +statement+ is invalid.
    def add(*statement); writable!; raise NotImplementedError end
    alias_method :<<, :add

    # Deletes +statement+ from the graph.
    #
    # Returns true, if the statement was deleted, false if it was not in the graph.
    #
    # Raises NotWritableError, if the graph is not writable.
    # Raises InvalidStatementError, if +statement+ is invalid.
    def delete(*statement); writable!; raise NotImplementedError end

    # True if +bnode+ is contained in at least one statement in the graph, false otherwise.
    def known?(bnode)
      if bnode?(bnode)
        each{|s| return true if s.subject == bnode || s.object == bnode}
      end
      false
    end

    # Performs a match against the given statement +fragment+, where blank nodes that do not appear
    # in the graph, and nils are considered variables.
    #
    # Variables will be bound on their first occurrence, and must match that binding on subsequent
    # occurrences.  For example,
    #   g.match(:a, :a, :b)
    # will match
    #   <http://example.com/one> <http://example.com/one> <http://example.com/three> .
    # but will not match
    #   <http://example.com/one> <http://example.com/two> <http://example.com/three> .
    #
    # Any nils will be replaced with new blank nodes, so that
    #   g.match(nil, nil, nil)
    # is equivalent to
    #   g.mach(Object.new, Object.new, Object.new)
    #
    # Yields each matched statement to the given block, or if no block is given, then returns a
    # graph containing all of the matched statements.
    def match(*fragment)
      statements = MemoryGraph.new
      begin
        sub, pred, obj = fragment.to_triple.map{|x| x || Object.new}
        each do |s|
          bindings = {}
          if RubyRDF.bnode?(sub)
            bindings[sub] = s.subject
          end

          if RubyRDF.bnode?(pred) && !bindings[pred]
            bindings[pred] = s.predicate
          end

          if RubyRDF.bnode?(obj) && !bindings[obj]
            bindings[obj] = s.object
          end

          if (bindings[sub] || sub) == s.subject &&
              (bindings[pred] || pred) == s.predicate &&
              (bindings[obj] || obj) == s.object
            if block_given?
              yield s
            else
              statements.add(s)
            end
          end
        end
      rescue InvalidStatementError
      end

      statements unless block_given?
    end

    # Returns the number of statements in the graph.
    def size
      inject(0){|sum,s| sum += 1}
    end

    # True if the graph is empty, false otherwise.
    def empty?
      size == 0
    end

    # Imports RDF statements from +io+ in the specified +format+ into the graph. Valid values for
    # +format+ are:
    # * :ntriples
    # * :rdfxml
    #
    # If +format+ is not given, then :ntriples is assumed.
    def import(io, format = nil)
      format ||= :ntriples

      case format
      when :ntriples
        NTriples::Reader.new(io).each{|s| add(s)}
      else
        raise UnknownFormatError
      end
    end

    # Exports the graph to +io+ in the specified +format+. Valid values for +format+ are:
    # * :ntriples
    # * :rdfxml
    #
    # If no +io+ is given, then a StringIO will be used, and the exported graph will be
    # returned.  Otherwise, +nil+ is returned.
    #
    # If +format+ is not given, then :ntriples is assumed.
    def export(format = nil, io = nil)
      format ||= :ntriples

      string_io = io.nil?
      io ||= StringIO.new

      case format
      when :ntriples
        NTriples::Writer.new(self).export(io)
      else
        raise UnknownFormatError
      end

      if string_io
        io.string
      end
    end

    # True if +node+ is a variable with respect to this graph, false otherwise.
    #
    # +node+ is a variable if it is a Symbol, or if it is a BNode that is unknown to this graph.
    def variable?(node)
      node.is_a?(Symbol) || (RubyRDF.bnode?(node) && !known?(node))
    end

    # True if this graph is writable, false otherwise.
    def writable?; false end

    # Raises NotWritableError, if this graph is not writable, returns nil otherwise.
    def writable!; raise NotWritableError unless writable? end

    # Adds each statement from the +statements+ Enumerable object.
    #
    # Raises NotWritableError if the graph is not writable.
    # Raises InvalidStatementError, if any of the statements are invalid.
    def add_all(*statements)
      statements.each{|s| add(*s)}
    end

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
    alias_method :clear, :delete_all

    #--
    # TODO document reify
    def reify(*statement)
      writable!
      s = statement.to_statement
      node = Object.new
      add(node, Namespaces.rdf::type, Namespaces.rdf::Statement)
      add(node, Namespaces.rdf::subject, s.subject)
      add(node, Namespaces.rdf::predicate, s.predicate)
      add(node, Namespaces.rdf::object, s.object)
      node
    end

    #--
    # TODO document
    def unreify(node)
      if known?(node)
        match(node, Namespaces.rdf::subject, nil){|s| subject = s.object}
        match(node, Namespaces.rdf::predicate, nil){|s| predicate = s.object}
        match(node, Namespaces.rdf::object, nil){|s| object = s.object}
        Statement.new(subject, predicate, object)
      end
    end

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
        bnodes[s] ||= Object.new if RubyRDF.bnode?(s)
        bnodes[o] ||= Object.new if RubyRDF.bnode?(o)

        add(bnodes[s] || s, p, bnodes[o] || o)
      end
    end
  end
end
