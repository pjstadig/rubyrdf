require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::Namespaces do
  before do
    RubyRDF::Namespaces.unregister_all!
    @prefix = "ex"
    @uri = "http://example.com/"
    RubyRDF::Namespaces.register(@prefix => @uri)
  end

  describe "register" do
    it "should define a class method" do
      RubyRDF::Namespaces.methods.should be_include(@prefix.to_s)
    end

    it "should define an instance method" do
      RubyRDF::Namespaces.instance_methods.should be_include(@prefix.to_s)
    end
  end

  describe "namespace" do
    it "should generate URIs using method_missing" do
      RubyRDF::Namespaces.ex.example.should == Addressable::URI.parse("http://example.com/example")
    end

    it "should generate URIs using const_missing" do
      RubyRDF::Namespaces.ex::Example.should == Addressable::URI.parse("http://example.com/Example")
    end

    it "should be a blank slate" do
      RubyRDF::Namespaces.ex.freeze.should == Addressable::URI.parse("http://example.com/freeze")
    end
  end

  it "should preregister rdf namespace" do
    RubyRDF::Namespaces.rdf::type.should ==
      Addressable::URI.parse("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
  end

  it "should preregister xsd namespace" do
    RubyRDF::Namespaces.xsd::string.should ==
      Addressable::URI.parse("http://www.w3.org/2001/XMLSchema#string")
  end

  it "should preregister rdfs namespace" do
    RubyRDF::Namespaces.rdfs::Class.should ==
      Addressable::URI.parse("http://www.w3.org/2000/01/rdf-schema#Class")
  end

  it "should preregister owl namespace" do
    RubyRDF::Namespaces.owl::Thing.should ==
      Addressable::URI.parse("http://www.w3.org/2002/07/owl#Thing")
  end

  it "should preregister dc namespace" do
    RubyRDF::Namespaces.dc::creator.should ==
      Addressable::URI.parse("http://purl.org/dc/elements/1.1/creator")
  end

  it "should unregister" do
    RubyRDF::Namespaces.unregister(:ex)
    RubyRDF::Namespaces.registered?(:ex).should be_false
  end

  describe "unregister_all" do
    it "should unregister all" do
      RubyRDF::Namespaces.unregister_all
      RubyRDF::Namespaces.registered?(:ex).should be_false
    end

    it "should not unregister defaults" do
      RubyRDF::Namespaces.unregister_all
      RubyRDF::Namespaces.registered?(:rdf).should be_true
      RubyRDF::Namespaces.registered?(:xsd).should be_true
      RubyRDF::Namespaces.registered?(:rdfs).should be_true
      RubyRDF::Namespaces.registered?(:owl).should be_true
      RubyRDF::Namespaces.registered?(:dc).should be_true
    end
  end
end
