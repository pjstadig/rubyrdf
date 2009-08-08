require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::TypedLiteral do
  before do
    @lexical_form = "example"
    @datatype_uri = Addressable::URI.parse("http://example.com/")
    @it = RubyRDF::TypedLiteral.new(@lexical_form, @datatype_uri)
  end

  describe "initialize" do
    it "should assign lexical_form" do
      @it.lexical_form.should == @lexical_form
    end

    it "should normalize lexical_form" do
      RubyRDF::TypedLiteral.new([0x2126].pack('U'), @datatype_uri).lexical_form.should == [0x03a9].pack('U')
    end

    it "should assign datatype_uri" do
      @it.datatype_uri.should == @datatype_uri
    end

    it "should normalize datatype_uri" do
      RubyRDF::TypedLiteral.new(@lexical_form,
                                Addressable::URI.parse("http://" + [0x2126].pack('U'))).
        datatype_uri.to_s.should == "http://" + [0x03a9].pack('U')
    end

    it "should normalize datatype_uri from a string" do
      RubyRDF::TypedLiteral.new(@lexical_form, "http://" + [0x2126].pack('U')).
        datatype_uri.to_s.should == "http://" + [0x03a9].pack('U')
    end

    it "should convert datatype_uri from a string to an URI" do
      RubyRDF::TypedLiteral.new(@lexical_form, @datatype_uri.to_s).datatype_uri.should == @datatype_uri
    end
  end

  describe "==" do
    it "should equal with same lexical_form and datatype_uri" do
      @it.should == RubyRDF::TypedLiteral.new(@lexical_form, @datatype_uri)
    end

    it "should not equal with different lexical_form and same datatype_uri" do
      @it.should_not == RubyRDF::TypedLiteral.new("different", @datatype_uri)
    end

    it "should not equal with same lexical_form and different datatype_uri" do
      @it.should_not == RubyRDF::TypedLiteral.new(@lexical_form, "http://different.com/")
    end

    it "should not equal nil" do
      @it.should_not == nil
    end

    it "should not equal non-TypedLiteral" do
      @it.should_not == Object.new
    end
  end

  it "should alias #== as #eql?" do
    @it.class.instance_method(:eql?).should == @it.class.instance_method(:==)
  end

  describe "hash" do
    it "should be equal with same lexical_form and datatype_uri" do
      @it.hash.should == RubyRDF::TypedLiteral.new(@lexical_form, @datatype_uri).hash
    end

    it "should not be equal with different lexical_form and same datatype_uri" do
      @it.hash.should_not == RubyRDF::TypedLiteral.new("different", @datatype_uri).hash
    end

    it "should not be equal with same lexical_form and different datatype_uri" do
      @it.hash.should_not == RubyRDF::TypedLiteral.new(@lexical_form, "http://different.com/").hash
    end
  end

  it "should return self for to_literal" do
    @it.to_literal.should equal(@it)
  end

  describe "to_ntriples" do
    it "should use NTriples.escape" do
      RubyRDF::NTriples.should_receive(:escape)
      RubyRDF::NTriples.should_receive(:escape_unicode)
      @it.to_ntriples
    end

    it "should be NTriples format" do
      @it.to_ntriples.should == %Q("#{@lexical_form}"^^<#{@datatype_uri}>)
    end
  end

  it "should alias #to_ntriples as #inspect" do
    @it.class.instance_method(:inspect).should == @it.class.instance_method(:to_ntriples)
  end

  it "should alias #to_ntriples as #to_s" do
    @it.class.instance_method(:to_s).should == @it.class.instance_method(:to_ntriples)
  end
end

describe "Integer#to_literal" do
  it "should convert to TypedLiteral" do
    2.to_literal.should == RubyRDF::TypedLiteral.new("2", RubyRDF::Namespace::XSD::integer)
  end
end

describe "Float#to_literal" do
  it "should convert to TypedLiteral" do
    1.5.to_literal.should == RubyRDF::TypedLiteral.new("1.5", RubyRDF::Namespace::XSD::double)
  end
end

describe "String#to_literal" do
  it "should convert to TypedLiteral" do
    "test".to_literal.should == RubyRDF::TypedLiteral.new("test", RubyRDF::Namespace::XSD::string)
  end
end

describe "TrueClass#to_literal" do
  it "should convert to TypedLiteral" do
    true.to_literal.should == RubyRDF::TypedLiteral.new("true", RubyRDF::Namespace::XSD::boolean)
  end
end

describe "FalseClass#to_literal" do
  it "should convert to TypedLiteral" do
    false.to_literal.should == RubyRDF::TypedLiteral.new("false", RubyRDF::Namespace::XSD::boolean)
  end
end

describe "Time#to_literal" do
  it "should convert to TypedLiteral" do
    it = Time.now
    it.to_literal.should ==
      RubyRDF::TypedLiteral.new(it.xmlschema, RubyRDF::Namespace::XSD::dateTime)
  end
end

describe "DateTime#to_literal" do
  it "should convert to TypedLiteral" do
    it = DateTime.new(2008, 12, 23, 0, 0, 0, -(5.0/24)).to_literal.should ==
      RubyRDF::TypedLiteral.new("2008-12-23T00:00:00-05:00", RubyRDF::Namespace::XSD::dateTime)
  end
end

describe "Date#to_literal" do
  it "should convert to TypedLiteral" do
    Date.civil(2008, 12, 23).to_literal.should ==
      RubyRDF::TypedLiteral.new("2008-12-23", RubyRDF::Namespace::XSD::date)
  end
end
