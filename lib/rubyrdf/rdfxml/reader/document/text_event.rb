module RubyRDF
  module RDFXML
    class Reader
      class Document
        class TextEvent
          attr_accessor :parent
          attr_accessor :string

          def initialize(parent, string)
            @parent = parent
            @string = string
          end

          def inspect
            "#<TextEvent #{string.dump}>"
          end
        end
      end
    end
  end
end
