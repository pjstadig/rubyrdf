module RubyRDF
  module NTriplesIO
    class Importer #:nodoc:
      def initialize(file, graph)
        @lineno = 1
        @charno = 1
        @file = file
        stretch_buf_to(1)
        @graph = graph
        @bnodes = { }
      end

      def import
        lines unless @file.eof?
      end

      def position
        "line: #{@lineno}, char: #{@charno}"
      end

      # All of the internal parsing methods follow
      def stretch_buf_to(x)
        @buf ||= ''
        goal = x - @buf.length
        while goal > 0 && !@file.eof?
          @buf << @file.getc.chr
          goal -= 1
          @charno += 1
        end
      end

      def consume(str = nil)
        if str.nil?
          stretch_buf_to(2)
          @buf.slice!(0).chr
        elsif test(str)
          stretch_buf_to(str.length + 1)

          if @buf.length >= str.length
            @buf.slice!(0, str.length)
          end
        else
          raise SyntaxError, "Expected #{str} at #{position}"
        end
      end

      def test(str)
        stretch_buf_to(str.length)
        @buf[0, str.length] == str
      end

      def peek
        @buf[0, 1]
      end

      def unescape(str)
        str
      end

      ## Parsing Methods
      def lines
        line
        while line?
          line
        end
      end

      def line
        @charno = 1
        if ws?
          wses
        end

        case
        when comment?
          comment
          eoln
        when triple?
          triple
          eoln
        when eoln? || @file.eof?
          eoln
        else
          raise SyntaxError, "Expected comment, triple, or empty line at #{position}"
        end
        @lineno += 1
      end

      def wses
        str = ws
        while ws?
          str << ws
        end
        str
      end

      def ws
        if space? || tab?
          consume
        else
          raise SyntaxError, "Expected space or tab at #{position}"
        end
      end

      def comment
        str = consume('#')
        while character_no_cr_or_lf?
          str = consume
        end
        str
      end

      def triple
        sub = subject
        wses
        pred = predicate
        wses
        obj = object
        if ws?
          wses
        end
        consume('.')
        if ws?
          wses
        end

        @graph.add(sub, pred, obj)
      end

      def subject
        if uriRef?
          uriRef
        elsif nodeId?
          nodeId
        else
          raise SyntaxError, "Expected uriRef or nodeId at #{position}"
        end
      end

      def predicate
        uriRef
      end

      def object
        if uriRef?
          uriRef
        elsif nodeId?
          nodeId
        elsif lit_string?
          literal
        end
      end

      def uriRef
        consume('<')
        node = Addressable::URI.parse(absoluteUri)
        consume('>')
        node
      end

      def absoluteUri
        str = character
        while character? && !test('>')
          str << character
        end
        unescape(str)
      end

      def nodeId
        consume('_:')
        @bnodes[name] ||= Object.new
      end

      def name
        str = ''
        if cap_az? || az?
          str << consume
        else
          raise SyntaxError, "Expected A-Z or a-z at #{position}"
        end

        while cap_az? || az? || num?
          str << consume
        end
        str
      end

      def literal
        str = lit_string
        if lang?
          lit_lang = lang
        elsif datatype?
          lit_dt = datatype
        end

        if lit_dt
          RubyRDF::TypedLiteral.new(str, lit_dt)
        else
          RubyRDF::PlainLiteral.new(str, lit_lang)
        end
      end

      def lit_string
        consume('"')
        str = string
        consume('"')
        unescape(str)
      end

      def string
        str = ''
        backslash = false
        while character? && (!test('"') || backslash)
          char = character
          if char == '\\' && !backslash
            backslash = true
          else
            if backslash
              backslash = false
              char = convert_backslash(char)
            end

            str << char
          end
        end
        str
      end

      def convert_backslash(char)
        case char
        when 'n'
          "\n"
        when 'r'
          "\r"
        when 't'
          "\t"
        when 'u'
          small_unicode_value
        when 'U'
          long_unicode_value
        else
          char
        end
      end

      def small_unicode_value
        value = ''
        while peek =~ /[A-Fa-f0-9]/
          value << consume
        end

        if value.size <= 4
          [value.hex].pack('U')
        else
          raise SyntaxError, 'Expected no more than four hexadecimal characters'
        end
      end

      def long_unicode_value
        value = ''
        while peek =~ /[A-Fa-f0-9]/
          value << consume
        end

        if value.size >= 5 && value.size <= 8
          [value.hex].pack('U')
        else
          raise SyntaxError, 'Expected between five and eight hexadecimal characters'
        end
      end

      def lang
        consume('@')
        language
      end

      def language
        str = ''
        if az?
          str << consume
        else
          raise SyntaxError, "Expected a-z at #{position}"
        end

        while az? && !test('-')
          str << consume
        end

        while test('-')
          str << consume
          if az? || num?
            str << consume
          else
            raise SyntaxError, "Expected a-z or number at #{position}"
          end

          while az? || num?
            str << consume
          end
        end
        str
      end

      def datatype
        consume('^^')
        uriRef
      end

      def character
        if character?
          consume
        else
          raise SyntaxError, "Expected character at #{position}"
        end
      end

      def eoln
        str = ''
        if cr?
          str = consume
          if lf?
            str << consume
          end
        elsif lf?
          str = consume
        elsif !@file.eof?
          raise SyntaxError, "Expected cr, lf, or crlf at #{position}"
        end
        str
      end

      ## Test Methods
      def line?
        ws? || comment? || uriRef? || nodeId? || eoln?
      end

      def comment?
        test('#')
      end

      def triple?
        subject?
      end

      def subject?
        uriRef? || nodeId?
      end

      def predicate?
        uriRef?
      end

      def object?
        uriRef? || nodeId? || lit_string?
      end

      def uriRef?
        test('<')
      end

      def nodeId?
        test("_:")
      end

      def lit_string?
        test('"')
      end

      def lang?
        test("@")
      end

      def datatype?
        test("^^")
      end

      def language_tag?
        ('a'..'z').include?(peek)
      end

      def ws?
        space? || tab?
      end

      def eoln?
        cr? || lf?
      end

      def space?
        peek == 0x20.chr
      end

      def cr?
        peek == 0xD.chr
      end

      def lf?
        peek == 0xA.chr
      end

      def tab?
        peek == 0x9.chr
      end

      def string?
        @file.eof? || character?
      end

      def cap_az?
        ('A'..'Z').include?(peek)
      end

      def az?
        ('a'..'z').include?(peek)
      end

      def num?
        ('0'..'9').include?(peek)
      end

      def name?
        cap_az? || az?
      end

      def absoluteUri?
        character?
      end

      def character_no_cr_or_lf?
        character? && !(cr? || lf?)
      end

      def character?
        (0x20.chr..0x7E.chr).include?(peek)
      end
    end
  end
end
