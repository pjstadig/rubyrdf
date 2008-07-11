module RDF
  class << self
    def unregister(*names)
      names.each do |n|
        @names.delete(@prefixes[n])
        @prefixes.delete(n)
        @namespaces.delete(n)
      end
    end
    
    def unregister_all!
      defaults = [:rdf, :rdfs, :xsd, :owl]
      @namespaces.keys.each do |name|
        unregister(name) unless defaults.include?(name)
      end
    end
    
    def register(namespaces)
      @namespaces ||= {}
      @names ||= {}
      @prefixes ||= {}
      
      namespaces.each do |name, prefix|
        @prefixes[name.to_sym] = prefix.to_s
        @names[prefix.to_s] = name
        
        mod = Module.new
        meta = class << mod
          self
        end
        
        code_block = <<-ENDL
          def method_missing(sym, *a, &b)
            raise ::ArgumentError, "Unexpected arguments for RDF::NS.expand" if a.size > 0
            ::RDF.expand_node(:#{name}, sym.to_s)
          end
          
          def const_missing(sym)
            ::RDF.expand_node(:#{name}, sym.to_s)
          end
          
          def [](name)
            ::RDF.expand_node(:#{name}, name.to_s)
          end
          
          [:type, :name, :id].each{|a| private(a)}
        ENDL
        
        meta.class_eval code_block
        
        @namespaces[name.to_sym] = mod
      end
    end
    
    def registered?(name)
      @namespaces.key?(name.to_sym)
    end
    
    def prefix(name)
      @prefixes[name.to_sym]
    end
    
    def expand_uri(name, local)
      "#{prefix(name)}#{local.to_s}"
    end
    
    def expand_node(name, local)
      RDF::URINode.new(expand_uri(name, local))
    end
    
    def [](name)
      @namespaces[name.to_sym]
    end
  end
  
  register(
    :rdf => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    :xsd => 'http://www.w3.org/2001/XMLSchema#',
    :rdfs => 'http://www.w3.org/2000/01/rdf-schema#',
    :owl => 'http://www.w3.org/2002/07/owl#')
end

class Object
  def blank_node?
    false
  end
  
  def uri_node?
    false
  end
  
  def typed_literal_node?
    false
  end
  
  def plain_literal_node?
    false
  end
  
  def resource?
    uri_node? || blank_node?
  end
  
  def literal_node?
    plain_literal_node? || typed_literal_node?
  end
  
  def node?
    resource? || literal_node?
  end
end