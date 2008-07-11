module RDF
  class URINode
    attr_reader :uri
    
    def initialize(uri)
      @uri = uri
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
      "<#{@uri}>"
    end
    alias_method :to_s, :to_ntriples
  end
end