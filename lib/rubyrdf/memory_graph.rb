require 'digest/md5'

module RubyRDF
  # An in-memory graph implementation.
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

    def each(&b) #:nodoc:
      @statements.each(&b)
    end

    def add(*statement) #:nodoc:
      index_statement(statement.to_statement)
    end

    def delete(*statement) #:nodoc:
      unindex_statement(statement.to_statement)
    end

    def match(*statement) #:nodoc:
      subject, predicate, object = statement.to_triple.map{|x| x || Object.new}
      MemoryGraph.new(*find_statements(subject, predicate, object))
    rescue InvalidStatementError
      MemoryGraph.new
    end

    def include?(*statement) #:nodoc:
      @statements.include?(statement.to_statement)
    end

    def size #:nodoc:
      @statements.size
    end

    def known?(bnode) #:nodoc:
      RubyRDF.bnode?(bnode) && @bnodes[bnode] > 0
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
      if RubyRDF.bnode?(key)
        idx[key] += 1
      end
    end

    def decrement(idx, key)
      if RubyRDF.bnode?(key)
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
  end
end
