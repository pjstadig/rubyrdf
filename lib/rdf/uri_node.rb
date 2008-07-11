module RDF
  class URINode < Node
    attr_reader :uri
    
    def initialize(uri)
      super()
      @uri = uri.chars.normalize(:c).to_s
    end
    
    def hash
      [763084702, @uri].hash
    end
    
    def ==(o)
      self.uri == o.uri
    rescue NoMethodError
      false
    end
    alias_method :eql?, :==
    
    def to_ntriples
      "<#{escape_ntriples(@uri)}>"
    end
    alias_method :to_s, :to_ntriples
    
    def uri_node?
      true
    end
  end
end