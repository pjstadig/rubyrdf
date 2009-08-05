require 'digest/md5'

module RubyRDF
  module Writer
    class NTriples
      class InvalidCharacter < RubyRDF::Error; end

      attr_reader :graph
      attr_reader :io

      def initialize(graph, io)
        @graph = graph
        @io = io
        @bnodes = {}
      end

      def export
        graph.each{|s| io.puts(export_statement(s))}
      end

      def export_statement(s)
        s.to_triple.map{|n| export_node(n)}.join(" ") + "."
      end

      def export_node(node)
        case node
        when Addressable::URI
          "<#{node}>"
        when PlainLiteral
          %Q("#{escape_string(node.lexical_form)}") +
            (node.language_tag ? "@#{node.language_tag}" : "")
        when TypedLiteral
          %Q("#{escape_string(node.lexical_form)}"^^<#{node.datatype_uri}>)
        else
          "_:bn#{@bnodes[node] ||= generate_bnode_name}"
        end
      end

      def escape_string(str)
        str.unpack('U*').map do |char|
          if char == 0x9
            '\\t'
          elsif char == 0xA
            '\\n'
          elsif char == 0xD
            '\\r'
          elsif char == 0x22
            '\\"'
          elsif char == 0x5C
            '\\\\'
          elsif char < 0x20
            encode_short_unicode(char)
          elsif char < 0x7F
            char.chr
          elsif char < 0x10000
            encode_short_unicode(char)
          elsif char < 0x110000
            encode_long_unicode(char)
          else
            raise InvalidCharacter
          end
        end.join
      end

      def encode_short_unicode(char)
        sprintf("\\u%04X", char)
      end

      def encode_long_unicode(char)
        sprintf("\\U%08X", char)
      end

      def generate_bnode_name
        Digest::MD5.hexdigest(Time.now.to_s)
      end
    end
  end
end
