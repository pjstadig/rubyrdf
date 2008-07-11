module RDF
  class BlankNode
    attr_reader :name
    
    def initialize(name = nil)
      @name = name || genname
    end
    
    def to_ntriples
      "_:#{@name}"
    end
    alias_method :to_s, :to_ntriples
    
    private
      def genname
        @@id ||= 0
        @@id += 1
        "bn#{@@id}"
      end
  end
end