module RDF
  module NTriplesHelper
      def escape_ntriples(str)
        str.unpack('U*').map! do |c|
          if 0x9 == c
            '\t'
          elsif 0xa == c
            '\n'
          elsif 0xd == c
            '\r'
          elsif 0x22 == c
            '\"'
          elsif 0x5c == c
            '\\\\'
          elsif (0x0..0x8).include?(c) ||
                (0xb..0xc).include?(c) ||
                (0xe..0x1f).include?(c) ||
                (0x7F..0xffff).include?(c)
            "\\u#{fixed_digit_hex(c, 4)}"
          elsif (0x20..0x21).include?(c) ||
                (0x23..0x5b).include?(c) ||
                (0x5d..0x7e).include?(c)
            c.chr
          elsif (0x10000..0x10ffff).include?(c)
            "\\U#{fixed_digit_hex(c, 8)}"
          end
        end.join
      end
      
      def fixed_digit_hex(num, digits)
        "%0#{digits}d" % num.to_s(16).to_i
      end
  end
end