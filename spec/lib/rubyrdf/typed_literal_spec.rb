require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::TypedLiteral do
  before do
    @lexical_form = "example"
    @datatype_uri = RubyRDF::URINode.new("http://example.com/")
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
end

describe "TypedLiteral conversions" do
  XSD = RubyRDF::Namespace::XSD

  describe "Integer#to_literal" do
    it "should convert to TypedLiteral" do
      2.to_literal.should == RubyRDF::TypedLiteral.new("2", XSD::integer)
    end
  end

  describe "Float#to_literal" do
    it "should convert to TypedLiteral" do
      1.5.to_literal.should == RubyRDF::TypedLiteral.new("1.5", XSD::double)
    end
  end

  describe "String#to_literal" do
    it "should convert to TypedLiteral" do
      "test".to_literal.should == RubyRDF::TypedLiteral.new("test", XSD::string)
    end
  end

  describe "TrueClass#to_literal" do
    it "should convert to TypedLiteral" do
      true.to_literal.should == RubyRDF::TypedLiteral.new("true", XSD::boolean)
    end
  end

  describe "FalseClass#to_literal" do
    it "should convert to TypedLiteral" do
      false.to_literal.should == RubyRDF::TypedLiteral.new("false", XSD::boolean)
    end
  end

  describe "Time#to_literal" do
    it "should convert to TypedLiteral" do
      it = Time.now
      it.to_literal.should ==
        RubyRDF::TypedLiteral.new(it.xmlschema, XSD::dateTime)
    end
  end

  describe "DateTime#to_literal" do
    it "should convert to TypedLiteral" do
      it = DateTime.new(2008, 12, 23, 0, 0, 0, -(5.0/24)).to_literal.should ==
        RubyRDF::TypedLiteral.new("2008-12-23T00:00:00-05:00", XSD::dateTime)
    end
  end

  describe "Date#to_literal" do
    it "should convert to TypedLiteral" do
      Date.civil(2008, 12, 23).to_literal.should ==
        RubyRDF::TypedLiteral.new("2008-12-23", XSD::date)
    end
  end

  describe "to_int" do
    it "should be 1 for '1'^^<xsd:integer>" do
      RubyRDF::TypedLiteral.new("1", XSD::integer).to_int.should == 1
    end

    it "should be 0 invalid integer" do
      RubyRDF::TypedLiteral.new("x", XSD::integer).to_int.should == 0
    end

    it "should raise NoMethodError for non-integer" do
      lambda {
        RubyRDF::TypedLiteral.new("1", XSD::string).to_int
      }.should raise_error(NoMethodError)
    end
  end

  describe "to_i" do
    it "should be 1 for '1'^^<xsd:integer>" do
      RubyRDF::TypedLiteral.new("1", XSD::integer).to_i.should == 1
    end

    it "should be 0 invalid integer" do
      RubyRDF::TypedLiteral.new("x", XSD::integer).to_i.should == 0
    end

    it "should be 0 non-integer" do
      RubyRDF::TypedLiteral.new("1", XSD::string).to_i.should == 0
    end
  end

  describe "to_f" do
    it "should be 1.1 for '1.1'^^<xsd:float>" do
      RubyRDF::TypedLiteral.new("1.1", XSD::float).to_f.should == 1.1
    end

    it "should be 0.0 invalid float" do
      RubyRDF::TypedLiteral.new("x", XSD::float).to_f.should == 0.0
    end

    it "should be 0.0 non-float" do
      RubyRDF::TypedLiteral.new("1.1", XSD::string).to_f.should == 0.0
    end
  end

  describe "to_str" do
    it "should be 'test' for 'test'^^<xsd:string>" do
      RubyRDF::TypedLiteral.new("test", XSD::string).to_str.should == "test"
    end

    it "should raise NoMethodError non-string" do
      lambda {
        RubyRDF::TypedLiteral.new("x", XSD::float).to_str
      }.should raise_error(NoMethodError)
    end
  end

  describe "to_s" do
    it "should be 'test' for 'test'^^<xsd:string>" do
      RubyRDF::TypedLiteral.new("test", XSD::string).to_s.should == "test"
    end

    it "should be '' non-string" do
      RubyRDF::TypedLiteral.new("test", XSD::float).to_s.should == ""
    end
  end

  describe "to_b" do
    it "should be true for 'true'^^<xsd:boolean>" do
      RubyRDF::TypedLiteral.new("true", XSD::boolean).to_b.should be_true
    end

    it "should be false for 'false'^^<xsd:boolean>" do
      RubyRDF::TypedLiteral.new("false", XSD::boolean).to_b.should be_false
    end

    it "should be nil invalid boolean" do
      RubyRDF::TypedLiteral.new("x", XSD::boolean).to_b.should be_nil
    end

    it "should be nil non-boolean" do
      RubyRDF::TypedLiteral.new("true", XSD::string).to_b.should be_nil
    end
  end

  describe "to_time" do
    it "should be 2008-12-23T10:20:30-05:00 for '2008-12-23T10:20:30-05:00'^^<xsd:dateTime>" do
      RubyRDF::TypedLiteral.new("2008-12-23T10:20:30-05:00", XSD::dateTime).to_time.should ==
        Time.utc(2008, 12, 23, 15, 20, 30)
    end

    it "should be nil invalid dateTime" do
      RubyRDF::TypedLiteral.new("x", XSD::dateTime).to_time.should be_nil
    end

    it "should be nil non-dateTime" do
      RubyRDF::TypedLiteral.new("2008-12-23T10:20:30-05:00", XSD::string).to_time.should be_nil
    end
  end

  describe "to_datetime" do
    it "should be 2008-12-23T10:20:30-05:00 for 'true'^^<xsd:dateTime>" do
      RubyRDF::TypedLiteral.new("2008-12-23T10:20:30-05:00", XSD::dateTime).to_datetime.should ==
        DateTime.civil(2008, 12, 23, 15, 20, 30)
    end

    it "should be nil invalid dateTime" do
      RubyRDF::TypedLiteral.new("x", XSD::dateTime).to_datetime.should be_nil
    end

    it "should be nil non-dateTime" do
      RubyRDF::TypedLiteral.new("2008-12-23T10:20:30-05:00", XSD::string).to_datetime.should be_nil
    end
  end

  describe "to_date" do
    it "should be 2008-12-23 for '2008-12-23'^^<xsd:date>" do
      RubyRDF::TypedLiteral.new("2008-12-23", XSD::date).to_date.should ==
        Date.civil(2008, 12, 23)
    end

    it "should be nil invalid date" do
      RubyRDF::TypedLiteral.new("x", XSD::date).to_date.should be_nil
    end

    it "should be nil non-date" do
      RubyRDF::TypedLiteral.new("2008-12-23", XSD::string).to_date.should be_nil
    end
  end

  describe "respond_to?" do
    it "should be true for :to_int if integer" do
      RubyRDF::TypedLiteral.new("1", XSD::integer).respond_to?(:to_int).should be_true
    end

    it "should be false for :to_int if non-integer" do
      RubyRDF::TypedLiteral.new("1", XSD::date).respond_to?(:to_int).should be_false
    end

    it "should be true for :to_str if string" do
      RubyRDF::TypedLiteral.new("test", XSD::string).respond_to?(:to_str).should be_true
    end

    it "should be false for :to_str if non-string" do
      RubyRDF::TypedLiteral.new("test", XSD::date).respond_to?(:to_str).should be_false
    end
  end
end
