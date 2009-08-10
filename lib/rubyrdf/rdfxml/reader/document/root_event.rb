module RubyRDF
  module RDFXML
    class Reader
      class Document
        class RootEvent
          attr_accessor(:document_element,
                        :base_uri,
                        :language)

          def initialize()
            @document_element = nil
            @base_uri = nil
            @language = nil
          end
        end
      end
    end
  end
end
