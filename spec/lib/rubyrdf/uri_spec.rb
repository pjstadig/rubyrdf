require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe URI, "#to_uri" do
  it "should parse an Addressable::URI" do
    URI.parse("http://example.com/").to_uri.should be_instance_of(Addressable::URI)
  end
end

describe Addressable::URI do
  it "should normalize uri" do
    Addressable::URI.parse("http://" + [0x2126].pack('U')).to_s.should == "http://" + [0x03a9].pack('U')
  end

  describe "#to_uri" do
    it "should be self" do
      @uri = Addressable::URI.parse("http://example.com/")
      @uri.to_uri.should equal(@uri)
    end
  end
end
