require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::Namespace do
  before do
    @it = RubyRDF::Namespace.new("http://example.org/")
  end

  it "should generate URIs using method_missing" do
    @it.example.should == RubyRDF::URINode.new("http://example.org/example")
  end

  it "should generate URIs using const_missing" do
    @it::Example.should == RubyRDF::URINode.new("http://example.org/Example")
  end

  it "should be a blank slate" do
    @it.freeze.should == RubyRDF::URINode.new("http://example.org/freeze")
  end

  it "should preregister rdf" do
    RubyRDF::Namespace::RDF::type.should == RubyRDF::URINode.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
  end

  it "should preregister xsd" do
    RubyRDF::Namespace::XSD::string.should == RubyRDF::URINode.new("http://www.w3.org/2001/XMLSchema#string")
  end

  it "should preregister rdfs" do
    RubyRDF::Namespace::RDFS::Class.should == RubyRDF::URINode.new("http://www.w3.org/2000/01/rdf-schema#Class")
  end

  it "should preregister owl" do
    RubyRDF::Namespace::OWL::Thing.should == RubyRDF::URINode.new("http://www.w3.org/2002/07/owl#Thing")
  end

  it "should preregister dc" do
    RubyRDF::Namespace::DC::creator.should == RubyRDF::URINode.new("http://purl.org/dc/elements/1.1/creator")
  end
end
