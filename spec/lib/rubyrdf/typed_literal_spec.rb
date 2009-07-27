require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::TypedLiteral do
  before do
    @lexical_form = "example"
    @datatype_uri = "http://example.com/"
    @it = RubyRDF::TypedLiteral.new(@lexical_form, @datatype_uri)
  end

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

  it "should alias #== as #eql?" do
    @it.class.instance_method(:eql?).should == @it.class.instance_method(:==)
  end

  it "should hash equal with same lexical_form and datatype_uri" do
    @it.hash.should == RubyRDF::TypedLiteral.new(@lexical_form, @datatype_uri).hash
  end

  it "should not hash equal with different lexical_form and same datatype_uri" do
    @it.hash.should_not == RubyRDF::TypedLiteral.new("different", @datatype_uri).hash
  end

  it "should not hash equal with same lexical_form and different datatype_uri" do
    @it.hash.should_not == RubyRDF::TypedLiteral.new(@lexical_form, "http://different.com/").hash
  end

  it "should return self for to_literal" do
    @it.to_literal.should equal(@it)
  end
end

describe "Integer#to_literal" do
  it "should convert to TypedLiteral" do
    2.to_literal.should == RubyRDF::TypedLiteral.new("2", RubyRDF::Namespaces.xsd::integer)
  end
end

describe "Float#to_literal" do
  it "should convert to TypedLiteral" do
    1.5.to_literal.should == RubyRDF::TypedLiteral.new("1.5", RubyRDF::Namespaces.xsd::double)
  end
end

describe "String#to_literal" do
  it "should convert to TypedLiteral" do
    "test".to_literal.should == RubyRDF::TypedLiteral.new("test", RubyRDF::Namespaces.xsd::string)
  end
end

describe "TrueClass#to_literal" do
  it "should convert to TypedLiteral" do
    true.to_literal.should == RubyRDF::TypedLiteral.new("true", RubyRDF::Namespaces.xsd::boolean)
  end
end

describe "FalseClass#to_literal" do
  it "should convert to TypedLiteral" do
    false.to_literal.should == RubyRDF::TypedLiteral.new("false", RubyRDF::Namespaces.xsd::boolean)
  end
end

describe "Time#to_literal" do
  it "should convert to TypedLiteral" do
    it = Time.now
    it.to_literal.should ==
      RubyRDF::TypedLiteral.new(it.xmlschema, RubyRDF::Namespaces.xsd::dateTime)
  end
end

describe "DateTime#to_literal" do
  it "should convert to TypedLiteral" do
    it = DateTime.new(2008, 12, 23, 0, 0, 0, -(5.0/24)).to_literal.should ==
      RubyRDF::TypedLiteral.new("2008-12-23T00:00:00-05:00", RubyRDF::Namespaces.xsd::dateTime)
  end
end

describe "Date#to_literal" do
  it "should convert to TypedLiteral" do
    Date.civil(2008, 12, 23).to_literal.should ==
      RubyRDF::TypedLiteral.new("2008-12-23", RubyRDF::Namespaces.xsd::date)
  end
end
