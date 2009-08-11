module RubyRDF
  class Query
    def initialize
      @select = []
      @bindings = {}
      @where = []
      if block_given?
        yield self
      end
    end

    def select(*a)
      @select = a if a.any?
      @select.dup
    end

    def where(*statement)
      @where << statement if statement.any?
      @where.dup
    end
    alias_method :and, :where

    def filter(&b)
      @filter = b if block_given?
      @filter.dup if @filter
    end
  end
end
