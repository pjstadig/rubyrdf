module RubyRDF
  module NTriples
    class Reader
      attr_reader :io

      def initialize(io)
        @io = io
        @lineno = 1
        @charno = 1
        @bnodes = {}
        @uri_cache = {}
      end

      def each
        while !eof? && triple?
          yield read
        end
      end

      def eof?
        non_triples
        @io.eof?
      end

      def read
        non_triples
        if triple?
          t = triple
          eoln
        else
          raise SyntaxError, "Expected triple at #{position}"
        end
        t
      end

      def non_triple?
        ws? || comment? || eoln?
      end

      def non_triple
        case
        when ws?
          wses
        when comment?
          comment
          eoln
        when eoln?
          eoln
        else
          raise SyntaxError, "Expected comment, triple, or empty line at #{position}"
        end
      end

      def non_triples
        while non_triple?
          non_triple
        end
      end

      def position
        "line: #{@lineno}, char: #{@charno}"
      end

      # All of the internal parsing methods follow
      def getc
        if @c
          c = @c
          @c = nil
          c
        else
          @io.getc
        end
      end

      def consume(str = nil)
        c = getc
        if !str.nil? && str != c
          raise SyntaxError, "Expected #{str.chr} at #{position}"
        end
        c
      end

      def consume_until(sep)
        c = getc
        if c != sep
          c.chr + @io.readline(sep.chr)
        else
          c.chr
        end
      end

      def test(str)
        peek == str
      end

      def peek
        @c ||= @io.getc
      end

      ## Parsing Methods
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
        str = consume(?#)
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
        consume(?.)
        if ws?
          wses
        end

        RubyRDF::Statement.new(sub, pred, obj)
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
        consume(?<)
        uri = absoluteUri
        @uri_cache[uri] ||= RubyRDF::URINode.new(uri)
      end

      def absoluteUri
        NTriples.unescape_unicode(character.chr +
                                  consume_until(?>).chomp(">"))
      end

      def nodeId
        consume(?_)
        consume(?:)
        @bnodes[name] ||= Object.new
      end

      def name
        str = StringIO.new
        if cap_az? || az?
          str.putc(consume)
        else
          raise SyntaxError, "Expected A-Z or a-z at #{position}"
        end

        while cap_az? || az? || num?
          str.putc(consume)
        end
        str.string
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
        consume(?")
        string
      end

      def string
        str = StringIO.new
        begin
          buf = consume_until(?")
          str.write(buf)
          b = buf.match(/(\\*)"$/)[1]
        end while b.size.odd?

        NTriples.unescape(str.string.chomp('"'))
      end

      def lang
        consume(?@)
        language
      end

      def language
        str = StringIO.new
        if az?
          str.putc(consume)
        else
          raise SyntaxError, "Expected a-z at #{position}"
        end

        while az? && !test(?-)
          str.putc(consume)
        end

        while test(?-)
          str.putc(consume)
          if az? || num?
            str.putc(consume)
          else
            raise SyntaxError, "Expected a-z or number at #{position}"
          end

          while az? || num?
            str.putc(consume)
          end
        end
        str.string
      end

      def datatype
        consume(?^)
        consume(?^)
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
        str = StringIO.new
        if cr?
          str.putc(consume)
          if lf?
            str.putc(consume)
          end
        elsif lf?
          str.putc(consume)
        elsif !@io.eof?
          raise SyntaxError, "Expected cr, lf, or crlf at #{position}"
        end
        @lineno += 1
        @charno = 1
        str.string
      end

      ## Test Methods
      def line?
        ws? || comment? || uriRef? || nodeId? || eoln?
      end

      def comment?
        test(?#)
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
        test(?<)
      end

      def nodeId?
        test(?_)
      end

      def lit_string?
        test(?")
      end

      def lang?
        test(?@)
      end

      def datatype?
        test(?^)
      end

      def language_tag?
        (?a..?z).include?(peek)
      end

      def ws?
        space? || tab?
      end

      def eoln?
        cr? || lf?
      end

      def space?
        peek == 0x20
      end

      def cr?
        peek == 0xD
      end

      def lf?
        peek == 0xA
      end

      def tab?
        peek == 0x9
      end

      def string?
        @io.eof? || character?
      end

      def cap_az?
        (?A..?Z).include?(peek)
      end

      def az?
        (?a..?z).include?(peek)
      end

      def num?
        (?0..?9).include?(peek)
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
        (0x20..0x7E).include?(peek)
      end
    end
  end
end
