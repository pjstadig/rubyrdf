module RDF
  class SparqlResult < Array
    class InvalidDocument < Error
      attr_reader :document
      
      def initialize(document)
        super("Invalid SPARQL Result Document")
        @document = document
      end
    end
    
    def initialize(result)
      super()
      bnodes = {}
      doc = REXML::Document.new(result)
      doc.elements.each('/sparql/results/result') do |r|
        binding = {}
        r.elements.each do |b|
          binding[b.attributes['name']] = parse_node(b.elements[1], bnodes)
        end
        self << binding
      end
    rescue REXML::ParseException
      raise InvalidDocument.new(result)
    end
    
    def parse_node(node, bnodes)
      case node.name
      when 'uri'
        RDF::URINode.new(node.text)
      when 'bnode'
        bnodes[node.text] ||= RDF::BlankNode.new
      when 'literal'
        if node.attributes.include?('datatype')
          RDF::TypedLiteralNode.new(node.text, node.attributes['datatype'])
        else
          RDF::PlainLiteralNode.new(node.text, node.attributes['lang'])
        end
      end
    end
  end
end