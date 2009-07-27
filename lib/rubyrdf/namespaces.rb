module RubyRDF
  # A registry of namespaces that can be used to generate URIs.  The following namespaces are
  # preregistered:
  #   :rdf  => "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  #   :xsd  => "http://www.w3.org/2001/XMLSchema#"
  #   :rdfs => "http://www.w3.org/2000/01/rdf-schema#"
  #   :owl  => "http://www.w3.org/2002/07/owl#"
  #   :dc   => "http://purl.org/dc/elements/1.1/"
  module Namespaces
    # Registers each namespace in the +namespaces+ hash.  Creates a class method and an instance
    # method for each prefix.  The methods return an anonymous Module that generates URIs from its
    # +method_missing+ and +const_missing+ methods.
    #
    # Example:
    #   RubyRDF::Namespaces.register(:ex => 'http://example.com/')
    #   RubyRDF::Namespaces.ex.test
    #   => #<Addressable::URI:0xfdbbed074 URI:http://example.com/test>
    #
    #   class SomeClass
    #     include RubyRDF::Namespaces
    #
    #     def return_an_uri
    #       ex::Constant
    #     end
    #   end
    #
    #   SomeClass.new.return_an_uri
    #   => #<Addressable::URI:0xfdbbe9cee URI:http://example.com/Constant>
    def self.register(namespaces)
      @@namespaces ||= {}
      namespaces.each do |prefix, uri|
        prefix = prefix.to_sym
        uri = uri.to_s

        @@namespaces[prefix] = Module.new
        @@namespaces[prefix].class_eval <<-END
          class << self
            instance_methods.each {|m| undef_method(m) unless m =~ /^__/}

            def method_missing(sym, *a, &b)
              Addressable::URI.parse("#{uri}\#{sym.to_s}")
            end

            def const_missing(sym)
              Addressable::URI.parse("#{uri}\#{sym.to_s}")
            end
          end
        END

        class_eval <<-END
          def self.#{prefix}
            @@namespaces[:#{prefix}]
          end

          def #{prefix}
            @@namespaces[:#{prefix}]
          end
        END
      end
    end

    register(:rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
             :xsd => "http://www.w3.org/2001/XMLSchema#",
             :rdfs => "http://www.w3.org/2000/01/rdf-schema#",
             :owl => "http://www.w3.org/2002/07/owl#",
             :dc => "http://purl.org/dc/elements/1.1/")
  end
end
