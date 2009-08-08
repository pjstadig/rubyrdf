require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe URI, "#to_uri" do
  it "should parse an Addressable::URI" do
    URI.parse("http://example.com/").to_uri.should be_instance_of(Addressable::URI)
  end
end

describe Addressable::URI do
  before do
    @it = Addressable::URI.parse("http://example.com/")
  end

  it "should normalize uri" do
    Addressable::URI.parse("http://" + [0x2126].pack('U')).to_s.should == "http://" + [0x03a9].pack('U')
  end

  describe "#to_uri" do
    it "should be self" do
      @it.to_uri.should equal(@it)
    end
  end

  describe "to_ntriples" do
    it "should use NTriples.escape_unicode" do
      RubyRDF::NTriples.should_receive(:escape_unicode)
      @it.to_ntriples
    end

    it "should be NTriples format" do
      @it.to_ntriples.should == "<http://example.com/>"
    end
  end
end
