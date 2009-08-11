module RubyRDF
  module RDFXML
    class Reader
      class Document
        class ElementEvent
          attr_accessor(:parent,
                        :local_name,
                        :namespace_name,
                        :base_uri,
                        :attributes,
                        :uri,
                        :li_counter,
                        :language,
                        :subject)

          def initialize(parent, local_name, namespace_name, attributes)
            @parent = parent
            @local_name = local_name.to_s
            @namespace_name = if namespace_name &&
                                  namespace_name.to_s[-1,1] != '/' &&
                                  namespace_name.to_s[-1,1] != '#'
                                namespace_name.to_s + '/'
                              else
                                namespace_name.to_s
                              end

            lang = attributes.select do |a|
              "#{a.uri}/#{a.localname}" == XML::lang.to_s
            end.first

            base = attributes.select do |a|
              "#{a.uri}/#{a.localname}" == XML::base.to_s
            end.first

            @base_uri = if base
                          b = Addressable::URI.parse(base.value.to_s)
                          if b.relative? && parent.base_uri
                            parent.base_uri.join(b)
                          else
                            b
                          end
                        else
                          parent.base_uri
                        end

            @attributes = attributes.delete_if do |a|
              a.prefix.to_s[0,3].downcase == 'xml' ||
              (a.prefix.to_s.strip.size == 0 && a.localname.to_s[0,3].downcase == 'xml')
            end.map{|a| AttributeEvent.new(self, a)}

            @li_counter = 1
            @uri = Addressable::URI.parse(@namespace_name + @local_name)

            @language = if lang
                          lang.value.to_s
                        else
                          parent.language
                        end
            @subject = nil
          end

          def resolve(uri)
            uri = Addressable::URI.parse(uri) unless uri.is_a?(Addressable::URI)
            if uri.relative? && base_uri
              base_uri.join(uri)
            else
              uri
            end
          end

          def has_attribute?(uri)
            a = attributes.select{|a| a.uri == uri}.first
            a if a && a.string_value.present?
          end
        end
      end
    end
  end
end
