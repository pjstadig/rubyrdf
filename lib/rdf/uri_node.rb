require 'rdf/ntriples_helper'

module RDF
  class URINode
    include NTriplesHelper
    
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
      "<#{escape_ntriples(@uri)}>"
    end
    alias_method :to_s, :to_ntriples
    
    def uri_node?
      true
    end
  end
end