module RubyRDF
  module RDFXML
    class Reader
      include Enumerable

      attr_reader :io

      def initialize(io, options = nil)
        @io = io
        @options = options || {}
      end

      def each(&b)
        Nokogiri::XML::SAX::Parser.new(Document.new(b, @options[:base_uri])).parse(io)
      end
    end
  end
end
