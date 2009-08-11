require File.expand_path(File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe RubyRDF do
  def ex
    RubyRDF::Namespace.new("http://example.org/")
  end

  describe 'uri?' do
    it "should be true for Addressable::URI" do
      RubyRDF.uri?(ex::example).should be_true
    end

    it "should be false for PlainLiteral" do
      RubyRDF.uri?(RubyRDF::PlainLiteral.new('test')).should be_false
    end

    it "should be false for TypedLiteral" do
      RubyRDF.uri?(2.to_literal).should be_false
    end

    it "should be false for Object" do
      RubyRDF.uri?(Object.new).should be_false
    end
  end

  describe 'literal?' do
    it "should be true for PlainLiteral" do
      RubyRDF.literal?(RubyRDF::PlainLiteral.new('test')).should be_true
    end

    it "should be true for TypedLiteral" do
      RubyRDF.literal?(2.to_literal).should be_true
    end

    it "should be false for Addressable::URI" do
      RubyRDF.literal?(ex::example).should be_false
    end

    it "should be false for Object" do
      RubyRDF.literal?(Object.new).should be_false
    end
  end

  describe 'bnode?' do
    it "should be true for Object" do
      RubyRDF.bnode?(Object.new).should be_true
    end

    it "should be false for Addressable::URI" do
      RubyRDF.bnode?(ex::example).should be_false
    end

    it "should be false for PlainLiteral" do
      RubyRDF.bnode?(RubyRDF::PlainLiteral.new('test')).should be_false
    end

    it "should be false for TypedLiteral" do
      RubyRDF.bnode?(2.to_literal).should be_false
    end
  end
end
