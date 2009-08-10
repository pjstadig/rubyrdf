module RubyRDF
  module RDFXML
    class Reader
      include Enumerable

      attr_reader :io

      def initialize(io)
        @io = io
      end

      def each(&b)
        Nokogiri::XML::SAX::Parser.new(Document.new(b)).parse(io)
      end
    end
  end
end
