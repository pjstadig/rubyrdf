require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe RubyRDF::NTriples::Reader do
  before do
    @ex = RubyRDF::Namespace.new('http://example.org/')
  end

  def ex
    @ex
  end

  def rdfs
    RubyRDF::Namespace::RDFS
  end

  def compare(actual, expected)
    if !((expected.subject.instance_of?(Object) && actual.subject.instance_of?(Object) ||
     expected.subject == actual.subject) &&
      expected.predicate == actual.predicate &&
      (expected.object.instance_of?(Object) && actual.object.instance_of?(Object) ||
       expected.object == actual.object))
      actual.should == expected
    end
  end

  it "should read NTriples test file" do
    File.open(File.dirname(__FILE__) + "/test.nt") do |f|
      reader = RubyRDF::NTriples::Reader.new(f)
      reader.eof?.should be_false
      compare(reader.read, RubyRDF::Statement.new(ex::resource1, ex::property, ex::resource2))
      compare(reader.read, RubyRDF::Statement.new(Object.new, ex::property, ex::resource2))
      compare(reader.read, RubyRDF::Statement.new(ex::resource2, ex::property, Object.new))
      compare(reader.read, RubyRDF::Statement.new(ex::resource3, ex::property, ex::resource2))
      compare(reader.read, RubyRDF::Statement.new(ex::resource4, ex::property, ex::resource2))
      compare(reader.read, RubyRDF::Statement.new(ex::resource5, ex::property, ex::resource2))
      compare(reader.read, RubyRDF::Statement.new(ex::resource6, ex::property, ex::resource2))
      compare(reader.read, RubyRDF::Statement.new(ex::resource7, ex::property, RubyRDF::PlainLiteral.new("simple literal")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource8, ex::property, RubyRDF::PlainLiteral.new("backslash:\\")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource9, ex::property, RubyRDF::PlainLiteral.new("dquote:\"")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource10, ex::property, RubyRDF::PlainLiteral.new("newline:\n")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource11, ex::property, RubyRDF::PlainLiteral.new("return\r")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource12, ex::property, RubyRDF::PlainLiteral.new("tab:\t")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource13, ex::property, ex::resource2))
      compare(reader.read, RubyRDF::Statement.new(ex::resource14, ex::property, RubyRDF::PlainLiteral.new("x")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource15, ex::property, Object.new))
      compare(reader.read, RubyRDF::Statement.new(ex::resource16, ex::property, RubyRDF::PlainLiteral.new([0xE9].pack("U"))))
      compare(reader.read, RubyRDF::Statement.new(ex::resource17, ex::property, RubyRDF::PlainLiteral.new([0x20AC].pack("U"))))
      compare(reader.read, RubyRDF::Statement.new(ex::resource21, ex::property, RubyRDF::TypedLiteral.new("", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource22, ex::property, RubyRDF::TypedLiteral.new(" ", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource23, ex::property, RubyRDF::TypedLiteral.new("x", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource23, ex::property, RubyRDF::TypedLiteral.new("\"", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource24, ex::property, RubyRDF::TypedLiteral.new("<a></a>", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource25, ex::property, RubyRDF::TypedLiteral.new("a <b></b>", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource26, ex::property, RubyRDF::TypedLiteral.new("a <b></b> c", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource26, ex::property, RubyRDF::TypedLiteral.new("a\n<b></b>\nc", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource27, ex::property, RubyRDF::TypedLiteral.new("chat", rdfs::XMLLiteral)))
      compare(reader.read, RubyRDF::Statement.new(ex::resource30, ex::property, RubyRDF::PlainLiteral.new("chat", "fr")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource31, ex::property, RubyRDF::PlainLiteral.new("chat", "en")))
      compare(reader.read, RubyRDF::Statement.new(ex::resource32, ex::property, RubyRDF::TypedLiteral.new("abc", ex::datatype1)))
      reader.should be_eof
    end
  end

  it "should decode unicode characters in URI" do
    reader = RubyRDF::NTriples::Reader.new(StringIO.new("<http://example.org/\\u20AC> <#{ex::property}> <#{ex::resource2}>.\n"))
    reader.read.should == RubyRDF::Statement.new(Addressable::URI.parse("http://example.org/#{[0x20AC].pack("U")}"), ex::property, ex::resource2)
  end

  it "should raise SyntaxError when missing space between nodes" do
    reader = RubyRDF::NTriples::Reader.new(StringIO.new("<http://example.org/\\u20AC><#{ex::property}><#{ex::resource2}>.\n"))
    lambda {
      reader.read
    }.should raise_error(RubyRDF::NTriples::SyntaxError)
  end
end
