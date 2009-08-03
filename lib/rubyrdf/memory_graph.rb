require 'digest/md5'

module RubyRDF
  # An in-memory graph implementation.
  #--
  # TODO Add imports/exports
  class MemoryGraph < Graph
    # Initializes the graph and adds +statements+ to it, if they are given.
    def initialize(*statements)
      reset_index
      add_all(*statements)
    end

    # Returns true.
    def writable?
      true
    end

    # Yields each statement to the block.
    def each(&b)
      @statements.each(&b)
    end

    # Performs a match against a statement fragment, where blank nodes that do not appear in the
    # graph, symbols, and nils are considered variables.
    #
    # See Graph#subgraph for more information.
    def subgraph(*statement)
      subject, predicate, object = statement.to_triple.map{|x| x || Object.new}
      MemoryGraph.new(*find_statements(subject, predicate, object))
    rescue InvalidStatementError
      MemoryGraph.new
    end

    # True if the graph contains +statement+, false otherwise.
    def include?(*statement)
      @statements.include?(statement.to_statement)
    end

    # Returns the number of statements in the graph.
    def size
      @statements.size
    end

    # True if +bnode+ is contained in at least one statement in the graph, false otherwise.
    def known?(bnode)
      @bnodes[bnode] > 0
    end

    # Adds +statement+ to the graph.
    #
    # Returns true if the statement was added, false if it was already in the graph.
    def add(*statement)
      index_statement(statement.to_statement)
    end

    # Deletes +statement+ from the graph.
    #
    # Returns true if the statement was deleted, false if it was already not in the graph.
    def delete(*statement)
      unindex_statement(statement.to_statement)
    end

    def to_ntriples
      # TODO this should use the export function
      bnodes = {}
      @statements.map do |s|
        statement_to_ntriples(s, bnodes)
      end.join("\n")
    end

    private
    def reset_index
      @statements = Set.new
      @bnodes = Hash.new{|h, k| h[k] = 0}
      @s_idx = Hash.new{|h, k| h[k] = Set.new}
      @p_idx = Hash.new{|h, k| h[k] = Set.new}
      @o_idx = Hash.new{|h, k| h[k] = Set.new}
      @sp_idx = Hash.new{|h, k| h[k] = Set.new}
      @po_idx = Hash.new{|h, k| h[k] = Set.new}
      @so_idx = Hash.new{|h, k| h[k] = Set.new}
    end

    def index_statement(statement)
      if @statements.add?(statement)
        increment(@bnodes, statement.subject)
        increment(@bnodes, statement.object)
        index(@s_idx, statement.subject, statement)
        index(@p_idx, statement.predicate, statement)
        index(@o_idx, statement.object, statement)
        index(@sp_idx, [statement.subject, statement.predicate], statement)
        index(@po_idx, [statement.predicate, statement.object], statement)
        index(@so_idx, [statement.subject, statement.object], statement)
        true
      end
    end

    def unindex_statement(statement)
      if @statements.delete?(statement)
        decrement(@bnodes, statement.subject)
        decrement(@bnodes, statement.object)
        unindex(@s_idx, statement.subject, statement)
        unindex(@p_idx, statement.predicate, statement)
        unindex(@o_idx, statement.object, statement)
        unindex(@sp_idx, [statement.subject, statement.predicate], statement)
        unindex(@po_idx, [statement.predicate, statement.object], statement)
        unindex(@so_idx, [statement.subject, statement.object], statement)
        true
      end
    end

    def index(idx, key, statement)
      idx[key].add(statement)
    end

    def unindex(idx, key, statement)
      idx[key].delete(statement)
      idx.delete(key) if idx[key].empty?
    end

    def increment(idx, key)
      if bnode?(key)
        idx[key] += 1
      end
    end

    def decrement(idx, key)
      if bnode?(key)
        idx[key] -= 1
        idx.delete(key) if idx[key] == 0
      end
    end

    def find_statements(subject, predicate, object)
      if variable?(subject) && variable?(predicate) && variable?(object)
        @statements.inject(Set.new) do |set, stmt|
          set.union(find_statements(subject == predicate ? stmt.predicate : subject,
                                    stmt.predicate,
                                    object == predicate ? stmt.predicate : object))
        end
      elsif variable?(predicate) && variable?(object)
        @s_idx[subject].inject(Set.new) do |set, stmt|
          set.union(find_statements(subject,
                                    stmt.predicate,
                                    predicate == object ? stmt.predicate : object))
        end
      elsif variable?(subject) && variable?(predicate)
        @o_idx[object].inject(Set.new) do |set, stmt|
          set.union(find_statements(subject == predicate ? stmt.predicate : subject,
                                    stmt.predicate,
                                    object))
        end
      elsif variable?(subject) && variable?(object)
        @p_idx[predicate].inject(Set.new) do |set, stmt|
          set.union(find_statements(stmt.subject,
                                    predicate,
                                    subject == object ? stmt.subject : object))
        end
      elsif variable?(object)
        @sp_idx[[subject, predicate]].dup
      elsif variable?(predicate)
        @so_idx[[subject, object]].dup
      elsif variable?(subject)
        @po_idx[[predicate, object]].dup
      elsif include?(subject, predicate, object)
        Set.new.add(Statement.new(subject, predicate, object))
      else
        []
      end.to_a
    end

    def statement_to_ntriples(statement, bnodes)
      statement.to_triple.map{|n| node_to_ntriples(n, bnodes)}.join(" ") + "."
    end

    def node_to_ntriples(node, bnodes)
      case node
      when Addressable::URI
        "<#{node}>"
      when TypedLiteral
        %Q("#{node.lexical_form}"^^<#{node.datatype_uri}>)
      when PlainLiteral
        %Q("#{node.lexical_form}") +
          (node.language_tag ? "@#{node.language_tag}" : "")
      else
        bnodes[node] ||= generate_bnode_name
        "_:#{bnodes[node]}"
      end
    end

    def generate_bnode_name
      "bn#{Digest::MD5.hexdigest(Time.now.to_s)}"
    end
  end
end
