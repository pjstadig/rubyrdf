require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::PlainLiteral, "without language_tag" do
  before do
    @lexical_form = "example"
    @it = RubyRDF::PlainLiteral.new(@lexical_form)
  end

  it "should equal with the same lexical_form" do
    @it.should == RubyRDF::PlainLiteral.new(@lexical_form)
  end

  it "should not equal with a different lexical_form" do
    @it.should_not == RubyRDF::PlainLiteral.new("different")
  end

  it "should not equal with a language tag" do
    @it.should_not == RubyRDF::PlainLiteral.new(@lexical_form, "df")
  end

  it "should not equal nil" do
    @it.should_not == nil
  end

  it "should not equal a non-PlainLiteral" do
    @it.should_not == Object.new
  end

  it "should alias #== to #eql?" do
    @it.class.instance_method(:eql?).should == @it.class.instance_method(:==)
  end

  it "should hash equal with the same lexical_form" do
    @it.hash.should == RubyRDF::PlainLiteral.new(@lexical_form).hash
  end

  it "should not hash equal with a different lexical_form" do
    @it.hash.should_not == RubyRDF::PlainLiteral.new("different").hash
  end

  it "should not hash equal with a language_tag" do
    @it.hash.should_not == RubyRDF::PlainLiteral.new(@lexical_form, "df").hash
  end

  it "should return self from to_literal" do
    @it.to_literal.should equal(@it)
  end
end

describe RubyRDF::PlainLiteral, "with language_tag" do
  before do
    @lexical_form = "example"
    @language_tag = "ex"
    @it = RubyRDF::PlainLiteral.new(@lexical_form, @language_tag)
  end

  it "should equal with the same lexical_form and language_tag" do
    @it.should == RubyRDF::PlainLiteral.new(@lexical_form, @language_tag)
  end

  it "should not equal with the same lexical_form and a different language_tag" do
    @it.should_not == RubyRDF::PlainLiteral.new(@lexical_form, "df")
  end

  it "should hash equal with the same lexical_form and language_tag" do
    @it.hash.should == RubyRDF::PlainLiteral.new(@lexical_form, @language_tag).hash
  end

  it "should not hash equal with the same lexical_form and a different language_tag" do
    @it.hash.should_not == RubyRDF::PlainLiteral.new(@lexical_form, "df").hash
  end
end
