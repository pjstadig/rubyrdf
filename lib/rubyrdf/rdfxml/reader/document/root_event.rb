module RubyRDF
  module RDFXML
    class Reader
      class Document
        class RootEvent
          attr_accessor(:document_element,
                        :base_uri,
                        :language)

          def initialize(base_uri)
            @document_element = nil
            @base_uri = base_uri && Addressable::URI.parse(base_uri)
            @language = nil
          end

          def inspect
            content = []
            content << (base_uri && base_uri.to_s) || 'nil'
            content << (language && language.to_s) || 'nil'
            content << (document_element && document_element.uri) || 'nil'
            "#<RootEvent #{content.join(" ")}>"
          end
        end
      end
    end
  end
end
