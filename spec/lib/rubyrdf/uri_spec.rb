require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe URI, "#to_uri" do
  it "should parse an Addressable::URI" do
    URI.parse("http://example.com/").to_uri.should be_instance_of(Addressable::URI)
  end

  it "should normalize uri" do
    URI.parse([0x2126].pack('U')).to_uri.to_s.should == [0x03a9].pack('U')
  end
end

describe Addressable::URI do
  it "should normalize uri" do
    Addressable::URI.parse([0x2126].pack('U')).to_s.should == [0x03a9].pack('U')
  end

  describe "#to_uri" do
    it "should be self" do
      @uri = Addressable::URI.parse("http://example.com/")
      @uri.to_uri.should equal(@uri)
    end
  end

  it "should be a node" do
    node = Addressable::URI.parse('http://stadig.name/')

    node.should be_uri_node
    node.should be_resource
    node.should be_node
  end
end
