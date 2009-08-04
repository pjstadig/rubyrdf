require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::NTriplesIO do
  def import
  end

  def export
  end

  include RubyRDF::NTriplesIO

  before do
    RubyRDF::Namespaces.register(:ex => 'http://example.org/')
  end

  def ex
    RubyRDF::Namespaces.ex
  end

  def rdfs
    RubyRDF::Namespaces.rdfs
  end

  describe :export do
    def each(&b)
      [RubyRDF::Statement.new(ex::a, ex::b, ex::c),
       RubyRDF::Statement.new(ex::a, ex::b, "test".to_literal),
       RubyRDF::Statement.new(ex::a, ex::b, RubyRDF::PlainLiteral.new("test")),
       RubyRDF::Statement.new(ex::a, ex::b, RubyRDF::PlainLiteral.new("test", "en")),
       RubyRDF::Statement.new(ex::a, ex::b, Object.new),
       RubyRDF::Statement.new(ex::a, ex::b, RubyRDF::PlainLiteral.new("\342\202\254\x9\xA\xD\x22\x5C\360\220\200\200"))
      ].each(&b)
    end

    it "should export" do
      io = StringIO.new
      Time.should_receive(:now).and_return(time = mock("time"))
      time.should_receive(:to_s).and_return("ab")
      export(io, :ntriples)
      io.string.should == <<ENDL
<http://example.org/a> <http://example.org/b> <http://example.org/c>.
<http://example.org/a> <http://example.org/b> "test"^^<http://www.w3.org/2001/XMLSchema#string>.
<http://example.org/a> <http://example.org/b> "test".
<http://example.org/a> <http://example.org/b> "test"@en.
<http://example.org/a> <http://example.org/b> _:bn187ef4436122d1cc2f40dc2b92f0eba0.
<http://example.org/a> <http://example.org/b> "\\u20AC\\t\\n\\r\\"\\\\\\U00010000".
ENDL
    end
  end

  describe :import do
    it "should parse NTriples test document" do
      should_receive(:add).with(ex::resource1, ex::property, ex::resource2)
      should_receive(:add).with(an_instance_of(Object), ex::property, ex::resource2)
      should_receive(:add).with(ex::resource2, ex::property, an_instance_of(Object))
      should_receive(:add).with(ex::resource3, ex::property, ex::resource2)
      should_receive(:add).with(ex::resource4, ex::property, ex::resource2)
      should_receive(:add).with(ex::resource5, ex::property, ex::resource2)
      should_receive(:add).with(ex::resource6, ex::property, ex::resource2)
      should_receive(:add).with(ex::resource7, ex::property, RubyRDF::PlainLiteral.new("simple literal"))
      should_receive(:add).with(ex::resource8, ex::property, RubyRDF::PlainLiteral.new("backslash:\\"))
      should_receive(:add).with(ex::resource9, ex::property, RubyRDF::PlainLiteral.new("dquote:\""))
      should_receive(:add).with(ex::resource10, ex::property, RubyRDF::PlainLiteral.new("newline:\n"))
      should_receive(:add).with(ex::resource11, ex::property, RubyRDF::PlainLiteral.new("return\r"))
      should_receive(:add).with(ex::resource12, ex::property, RubyRDF::PlainLiteral.new("tab:\t"))
      should_receive(:add).with(ex::resource13, ex::property, ex::resource2)
      should_receive(:add).with(ex::resource14, ex::property, RubyRDF::PlainLiteral.new("x"))
      should_receive(:add).with(ex::resource15, ex::property, anything())
      should_receive(:add).with(ex::resource16, ex::property, RubyRDF::PlainLiteral.new("\303\251"))
      should_receive(:add).with(ex::resource17, ex::property, RubyRDF::PlainLiteral.new("\342\202\254"))
      should_receive(:add).with(ex::resource21, ex::property, RubyRDF::TypedLiteral.new("", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource22, ex::property, RubyRDF::TypedLiteral.new(" ", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource23, ex::property, RubyRDF::TypedLiteral.new("x", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource23, ex::property, RubyRDF::TypedLiteral.new("\"", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource24, ex::property, RubyRDF::TypedLiteral.new("<a></a>", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource25, ex::property, RubyRDF::TypedLiteral.new("a <b></b>", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource26, ex::property, RubyRDF::TypedLiteral.new("a <b></b> c", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource26, ex::property, RubyRDF::TypedLiteral.new("a\n<b></b>\nc", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource27, ex::property, RubyRDF::TypedLiteral.new("chat", rdfs::XMLLiteral))
      should_receive(:add).with(ex::resource30, ex::property, RubyRDF::PlainLiteral.new("chat", "fr"))
      should_receive(:add).with(ex::resource31, ex::property, RubyRDF::PlainLiteral.new("chat", "en"))
      should_receive(:add).with(ex::resource32, ex::property, RubyRDF::TypedLiteral.new("abc", ex::datatype1))
      import(StringIO.new(<<ENDL), :ntriples)
#
# Copyright World Wide Web Consortium, (Massachusetts Institute of
# Technology, Institut National de Recherche en Informatique et en
# Automatique, Keio University).
#
# All Rights Reserved.
#
# Please see the full Copyright clause at
# <http://www.w3.org/Consortium/Legal/copyright-software.html>
#
# Test file with a variety of legal N-Triples
#
# Dave Beckett - http://purl.org/net/dajobe/
#
# $Id: test.nt,v 1.7 2003/10/06 15:52:19 dbeckett2 Exp $
#
#####################################################################

# comment lines
                   # comment line after whitespace
# empty blank line, then one with spaces and tabs


<http://example.org/resource1> <http://example.org/property> <http://example.org/resource2> .
_:anon <http://example.org/property> <http://example.org/resource2> .
<http://example.org/resource2> <http://example.org/property> _:anon .
# spaces and tabs throughout:
         <http://example.org/resource3>          <http://example.org/property>   <http://example.org/resource2>         .

# line ending with CR NL (ASCII 13, ASCII 10)
<http://example.org/resource4> <http://example.org/property> <http://example.org/resource2> .

# 2 statement lines separated by single CR (ASCII 10)
<http://example.org/resource5> <http://example.org/property> <http://example.org/resource2> .
<http://example.org/resource6> <http://example.org/property> <http://example.org/resource2> .


# All literal escapes
<http://example.org/resource7> <http://example.org/property> "simple literal" .
<http://example.org/resource8> <http://example.org/property> "backslash:\\\\" .
<http://example.org/resource9> <http://example.org/property> "dquote:\\"" .
<http://example.org/resource10> <http://example.org/property> "newline:\\n" .
<http://example.org/resource11> <http://example.org/property> "return\\r" .
<http://example.org/resource12> <http://example.org/property> "tab:\\t" .

# Space is optional before final .
<http://example.org/resource13> <http://example.org/property> <http://example.org/resource2>.
<http://example.org/resource14> <http://example.org/property> "x".
<http://example.org/resource15> <http://example.org/property> _:anon.

# \u and \U escapes
# latin small letter e with acute symbol \u00E9 - 3 UTF-8 bytes #xC3 #A9
<http://example.org/resource16> <http://example.org/property> "\\u00E9" .
# Euro symbol \u20ac  - 3 UTF-8 bytes #xE2 #x82 #xAC
<http://example.org/resource17> <http://example.org/property> "\\u20AC" .
# resource18 test removed
# resource19 test removed
# resource20 test removed

# XML Literals as Datatyped Literals
<http://example.org/resource21> <http://example.org/property> ""^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource22> <http://example.org/property> " "^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource23> <http://example.org/property> "x"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource23> <http://example.org/property> "\\""^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource24> <http://example.org/property> "<a></a>"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource25> <http://example.org/property> "a <b></b>"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource26> <http://example.org/property> "a <b></b> c"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource26> <http://example.org/property> "a\\n<b></b>\\nc"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
<http://example.org/resource27> <http://example.org/property> "chat"^^<http://www.w3.org/2000/01/rdf-schema#XMLLiteral> .
# resource28 test removed 2003-08-03
# resource29 test removed 2003-08-03

# Plain literals with languages
<http://example.org/resource30> <http://example.org/property> "chat"@fr .
<http://example.org/resource31> <http://example.org/property> "chat"@en .

# Typed Literals
<http://example.org/resource32> <http://example.org/property> "abc"^^<http://example.org/datatype1> .
# resource33 test removed 2003-08-03
ENDL
    end
  end
end
