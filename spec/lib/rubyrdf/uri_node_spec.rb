require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::URINode do
  before do
    @uri = Addressable::URI.parse("http://example.com/")
    @it = RubyRDF::URINode.new(@uri)
  end

  describe "initialize" do
    it "should assign uri" do
      @it.uri.should == @uri.to_s
    end

    it "should normalize uri" do
      RubyRDF::URINode.new(Addressable::URI.parse("http://" + [0x2126].pack('U'))).
        uri.should == "http://" + [0x03a9].pack('U')
    end

    it "should normalize datatype_uri from a string" do
      RubyRDF::URINode.new("http://" + [0x2126].pack('U')).
        uri.should == "http://" + [0x03a9].pack('U')
    end
  end

  describe "==" do
    it "should equal with same uri" do
      @it.should == RubyRDF::URINode.new(@uri)
    end

    it "should not equal with different uri" do
      @it.should_not == RubyRDF::URINode.new("http://different.com/")
    end

    it "should not equal nil" do
      @it.should_not == nil
    end

    it "should not equal non-URINode" do
      @it.should_not == Object.new
    end
  end

  it "should alias #== as #eql?" do
    @it.class.instance_method(:eql?).should == @it.class.instance_method(:==)
  end

  describe "hash" do
    it "should be equal with same uri" do
      @it.hash.should == RubyRDF::URINode.new(@uri).hash
    end

    it "should not be equal with different uri" do
      @it.hash.should_not == RubyRDF::URINode.new("http://different.com/").hash
    end
  end

  it "should return self for to_uri" do
    @it.to_uri.should equal(@it)
  end

  describe "to_ntriples" do
    it "should use NTriples.escape" do
      RubyRDF::NTriples.should_receive(:escape_unicode)
      @it.to_ntriples
    end

    it "should be NTriples format" do
      @it.to_ntriples.should == "<#{@uri}>"
    end
  end

  it "should alias #to_ntriples as #inspect" do
    @it.class.instance_method(:inspect).should == @it.class.instance_method(:to_ntriples)
  end

  it "should alias #uri as #to_s" do
    @it.class.instance_method(:to_s).should == @it.class.instance_method(:uri)
  end
end

describe URI, "to_uri" do
  it "should return URINode" do
    URI.parse("http://example.com/").to_uri.should ==
      RubyRDF::URINode.new("http://example.com/")
  end

  it "should cache URINode" do
    uri = URI.parse("http://example.com/")
    node = uri.to_uri
    uri.to_uri.should equal(node)
  end
end

describe Addressable::URI, "to_uri" do
  it "should return URINode" do
    Addressable::URI.parse("http://example.com/").to_uri.should ==
      RubyRDF::URINode.new("http://example.com/")
  end

  it "should cache URINode" do
    uri = Addressable::URI.parse("http://example.com/")
    node = uri.to_uri
    uri.to_uri.should equal(node)
  end
end
