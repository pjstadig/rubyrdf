require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::BNode do
  it "should be a node" do
    node = RubyRDF::BNode.new

    node.should be_blank_node
    node.should be_resource
    node.should be_node
  end
end
