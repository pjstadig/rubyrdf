module RubyRDF
  #--
  # TODO [] method
  # TODO method to find a namespace base on an URI?
  # TODO keep track of namespaces and their URIs
  # TODO should implement respond_to?
  class Namespace
    def self.new(uri)
      m = Module.new
      m.class_eval <<-END
      class << self
        instance_methods.each {|m| undef_method(m) unless m =~ /^__/}

        def method_missing(sym, *a, &b)
          @cache ||= {}
          @cache[sym.to_s] ||= RubyRDF::URINode.new("#{uri}\#{sym.to_s}")
        end

        def const_missing(sym)
          @cache ||= {}
          @cache[sym.to_s] ||= RubyRDF::URINode.new("#{uri}\#{sym.to_s}")
        end
      end
      END
      m
    end


    RDF = new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    XSD = new("http://www.w3.org/2001/XMLSchema#")
    RDFS = new("http://www.w3.org/2000/01/rdf-schema#")
    OWL = new("http://www.w3.org/2002/07/owl#")
    DC = new("http://purl.org/dc/elements/1.1/")
  end
end
