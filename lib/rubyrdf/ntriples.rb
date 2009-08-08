module RubyRDF
  module NTriples
    def self.escape(str)
      str = str.dup
      str.gsub!("\\", '\\\\\\')
      str.gsub!("\t", '\\t')
      str.gsub!("\n", '\\n')
      str.gsub!("\r", '\\r')
      str.gsub!("\"", '\\"')
      escape_unicode(str)
    end

    def self.escape_unicode(str)
      str.unpack('U*').map do |char|
        if char > 0x10FFFF
          raise InvalidCharacterError, "#{char} is out of range for a Unicode character"
        end

        case char
        when 0x0..0x8, 0xB..0xC, 0xE..0x1F, 0x7F..0xFFFF
          sprintf("\\u%04X", char)
        when 0x10000..0x10FFFF
          sprintf("\\U%08X", char)
        else
          char.chr
        end
      end.join
    end

    def self.unescape(str)
      str = str.dup
      str.gsub!('\\t', "\t")
      str.gsub!('\\n', "\n")
      str.gsub!('\\r', "\r")
      str.gsub!('\\"', "\"")
      str.gsub!('\\\\', "\\")
      unescape_unicode(str)
    end

    def self.unescape_unicode(str)
      str = str.dup
      str.gsub!(/\\u([0-9a-zA-Z]{0,4})/) do |m|
        raise SyntaxError, "\\u#{$1} expected to have four hexademical digits" unless $1.size == 4
        [$1.hex].pack('U')
      end
      str.gsub!(/\\U([0-9a-zA-Z]{0,8})/) do |m|
        raise SyntaxError, "\\U#{$1} expected to have eight hexademical digits" unless $1.size == 8
        char = $1.hex
        raise InvalidCharacterError, "#{char} is out of range for a Unicode character" if char > 0x10FFFF
        [char].pack('U')
      end
      str
    end
  end
end
