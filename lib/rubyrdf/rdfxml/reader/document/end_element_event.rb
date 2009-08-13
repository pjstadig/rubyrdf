module RubyRDF
  module RDFXML
    class Reader
      class Document
        class EndElementEvent
          attr_accessor(:local_name,
                        :namespace_name)

          def initialize(local_name, namespace_name)
            @local_name = local_name
            @namespace_name = namespace_name
          end

          def inspect
            "#<EndElementEvent>"
          end
        end
      end
    end
  end
end
