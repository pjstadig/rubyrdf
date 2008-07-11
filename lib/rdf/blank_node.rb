module RDF
  class BlankNode < Node
    attr_reader :name
    
    def initialize(name = nil)
      super()
      @name = name || genname
    end
    
    def to_ntriples
      "_:#{@name}"
    end
    alias_method :to_s, :to_ntriples
    
    def blank_node?
      true
    end
    
    private
      def genname
        @@id ||= 0
        @@id += 1
        "bn#{@@id}"
      end
  end
end