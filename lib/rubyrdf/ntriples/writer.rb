require 'digest/md5'

module RubyRDF
  module NTriples
    class Writer
      attr_reader :graph

      def initialize(graph)
        @graph = graph
        @bnodes = {}
      end

      def export(io)
        graph.each{|s| io.puts(export_statement(s))}
      end

      def export_statement(s)
        s.to_triple.map{|n| export_node(n)}.join(" ") + "."
      end

      def export_node(node)
        case node
        when Addressable::URI, PlainLiteral, TypedLiteral
          node.to_ntriples
        else
          "_:bn#{@bnodes[node] ||= RubyRDF.generate_bnode_name}"
        end
      end
    end
  end
end
