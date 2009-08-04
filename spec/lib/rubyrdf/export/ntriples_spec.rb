require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe RubyRDF::Export::NTriples do
  def ex
    RubyRDF::Namespaces.ex
  end

  def xsd
    RubyRDF::Namespaces.xsd
  end

  before do
    RubyRDF::Namespaces.register(:ex => "http://example.com/")
    @graph = RubyRDF::MemoryGraph.new()
    @io = StringIO.new
    @it = RubyRDF::Export::NTriples.new(@graph, @io)
  end

  describe "export_node" do
    it "should export URI" do
      @it.export_node(ex::resource).should == "<#{ex::resource}>"
    end

    it "should export bnode" do
      @it.should_receive(:generate_bnode_name).and_return("name")
      @it.export_node(Object.new).should == "_:bnname"
    end

    it "should cache bnode name" do
      @it.should_receive(:generate_bnode_name).and_return("name")
      obj = Object.new
      @it.export_node(obj).should == "_:bnname"
      @it.export_node(obj).should == "_:bnname"
    end

    it "should export PlainLiteral" do
      @it.should_receive(:escape_string).with("test").and_return("test")
      @it.export_node(RubyRDF::PlainLiteral.new("test")).should ==
        %Q("test")
    end

    it "should export PlainLiteral with language tag" do
      @it.should_receive(:escape_string).with("test").and_return("test")
      @it.export_node(RubyRDF::PlainLiteral.new("test", "en")).should ==
        %Q("test"@en)
    end

    it "should export TypedLiteral" do
      @it.should_receive(:escape_string).with("2").and_return("2")
      @it.export_node(2.to_literal).should ==
        %Q("2"^^<#{xsd::integer}>)
    end
  end

  describe "escape_string" do
    it "should encode 0x0" do
      @it.escape_string("\x0").should == "\\u0000"
    end

    it "should encode 0x8" do
      @it.escape_string("\x8").should == "\\u0008"
    end

    it "should encode tab" do
      @it.escape_string("\x9").should == "\\t"
    end

    it "should encode newline" do
      @it.escape_string("\xA").should == "\\n"
    end

    it "should encode 0xB" do
      @it.escape_string("\xB").should == "\\u000B"
    end

    it "should encode 0xC" do
      @it.escape_string("\xC").should == "\\u000C"
    end

    it "should encode carriage return" do
      @it.escape_string("\xD").should == "\\r"
    end

    it "should encode 0xE" do
      @it.escape_string("\xE").should == "\\u000E"
    end

    it "should encode 0x1F" do
      @it.escape_string("\x1F").should == "\\u001F"
    end

    it "should not encode 0x20" do
      @it.escape_string("\x20").should == "\x20"
    end

    it "should not encode 0x21" do
      @it.escape_string("\x20").should == "\x20"
    end

    it "should encode dquote" do
      @it.escape_string("\x22").should == '\\"'
    end

    it "should not encode 0x23" do
      @it.escape_string("\x23").should == "\x23"
    end

    it "should not encode 0x5B" do
      @it.escape_string("\x5B").should == "\x5B"
    end

    it "should encode backslash" do
      @it.escape_string("\x5C").should == '\\\\'
    end

    it "should not encode 0x5D" do
      @it.escape_string("\x5D").should == "\x5D"
    end

    it "should not encode 0x7E" do
      @it.escape_string("\x7E").should == "\x7E"
    end

    it "should encode 0x7F" do
      @it.escape_string("\x7F").should == "\\u007F"
    end

    it "should encode 0xFFFF" do
      @it.escape_string([0xFFFF].pack("U")).should == "\\uFFFF"
    end

    it "should encode 0x10000" do
      @it.escape_string([0x10000].pack("U")).should == "\\U00010000"
    end

    it "should encode 0x10FFFF" do
      @it.escape_string([0x10FFFF].pack("U")).should == "\\U0010FFFF"
    end

    it "should raise invalid character" do
      lambda {
        @it.escape_string([0x110000].pack("U"))
      }.should raise_error(RubyRDF::Export::NTriples::InvalidCharacter)
    end
  end
end
