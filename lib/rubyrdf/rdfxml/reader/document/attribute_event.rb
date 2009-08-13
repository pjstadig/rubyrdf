module RubyRDF
  module RDFXML
    class Reader
      class Document
        class AttributeEvent
          attr_accessor(:parent,
                        :local_name,
                        :namespace_name,
                        :string_value,
                        :uri)

          def initialize(parent, attribute)
            @parent = parent
            @local_name = attribute.localname.to_s
            @namespace_name = if attribute.uri
                                if attribute.uri.to_s[-1,1] != '/' &&
                                    attribute.uri.to_s[-1,1] != '#'
                                  attribute.uri.to_s + '/'
                                else
                                  attribute.uri.to_s
                                end
                              end
            @string_value = attribute.value.to_s.gsub(/&#(\d+);/){|m| [$1.to_i].pack("U")}
            @uri = if @namespace_name
                     Addressable::URI.parse(@namespace_name + @local_name)
                   elsif ['ID', 'about', 'resource', 'parseType', 'type'].include?(@local_name)
                     Addressable::URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns##{@local_name}")
                   else
                     raise SyntaxError, "Non-namespaced attributes are not allowed"
                   end
          end

          def inspect
            "#<AttributeEvent #{uri}>"
          end
        end
      end
    end
  end
end
