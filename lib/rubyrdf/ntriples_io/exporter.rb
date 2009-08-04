module RubyRDF
  module NTriplesIO
    class Exporter
      def initialize(io, graph)
        @io = io
        @graph = graph
      end

      def export
        @graph.each do |s|
          export_statement(s)
        end
      end

      def export_statement(s)
        @io.puts s.to_triple.map{|n| export_node(n)}.join(" ") + "."
      end

      def export_node(n)
        case n
        when Addressable::URI
          "<#{n}>"
        when TypedLiteral
          %Q("#{export_string(n.lexical_form)}"^^<#{n.datatype_uri}>)
        when PlainLiteral
          %Q("#{export_string(n.lexical_form)}") +
            (n.language_tag ? "@#{n.language_tag}" : "")
        else
          "_:bn#{generate_bnode_name}"
        end
      end

      def generate_bnode_name
        Digest::MD5.hexdigest(Time.now.to_s)
      end

      def export_string(str)
        str.unpack('U*').map do |c|
          if c == 0x9
            '\\t'
          elsif c == 0xA
            '\\n'
          elsif c == 0xD
            '\\r'
          elsif c == 0x22
            '\\"'
          elsif c == 0x5c
            '\\\\'
          elsif c < 128
            c.chr
          elsif c < 0x10000
            sprintf("\\u%04X", c)
          else
            sprintf("\\U%08X", c)
          end
        end.join
      end
    end
  end
end
