require 'rdf/ntriples_helper'

module RDF
  class TypedLiteralNode
    include NTriplesHelper
    
    attr_reader :lexical_form, :datatype_uri
    
    def initialize(lexical_form, datatype_uri)
      @lexical_form = lexical_form
      @datatype_uri = datatype_uri
    end
    
    def hash
      [-1025818701, @lexical_form, @datatype_uri].hash
    end
    
    def ==(o)
      self.lexical_form == o.lexical_form &&
        self.datatype_uri == o.datatype_uri
    rescue NoMethodError
      false
    end
    alias_method :eql?, :==
    
    def to_ntriples
      %Q("#{escape_ntriples(@lexical_form)}"^^<#{escape_ntriples(@datatype_uri)}>)
    end
    alias_method :to_s, :to_ntriples
  end
end