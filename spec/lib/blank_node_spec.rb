require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe RDF::BlankNode do
  it "should initialize name" do
    RDF::BlankNode.new('test').name.should == 'test'
  end

  it "should generate a name" do
    RDF::BlankNode.new.name.should_not be_nil
  end

  it "should export to NTriples" do
    RDF::BlankNode.new('test').to_ntriples.should == '_:test'
    RDF::BlankNode.new('test').to_s.should == '_:test'
  end

  it "shoould be a blank node" do
    node = RDF::BlankNode.new

    node.should be_blank_node
    node.should be_resource
    node.should be_node
  end
end
