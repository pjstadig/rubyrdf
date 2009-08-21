require 'rubyrdf/graph'

module RubyRDF
  class FederatedGraph < Graph
    attr_reader :sources
    attr_accessor :sink

    def initialize(*sources)
      super()
      @sources = sources.dup
      @sink = sources.last
    end

    def writable?
      @sink && @sink.writable?
    end

    def add(*statement)
      raise NotWritableError, "sink is not writable" if !writable?
      @sink.add(*statement)
    end

    def delete(*statement)
      raise NotWritableError, "sink is not writable" if !writable?
      @sink.delete(*statement)
    end

    def import(*a, &b)
      raise NotWritableError, "sink is not writable" if !writable?
      @sink.import(*a, &b)
    end

    # TODO export?

    def include?(*statement)
      @sources.any?{|x| x.include?(*statement)}
    end

    def known?(node)
      @sources.any?{|x| x.known?(node)}
    end

    def size
      @sources.inject(0){|sum, src| sum += src.size}
    end

    def sink=(sink)
      @sources.delete(@sink) if @sink
      @sources << sink if sink
      @sink = sink
    end
  end
end
