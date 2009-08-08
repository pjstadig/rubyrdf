require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe RubyRDF::NTriples::Writer do
  before do
    @ex = RubyRDF::Namespace.new('http://example.org/')
    @graph = RubyRDF::MemoryGraph.new()
    @it = RubyRDF::NTriples::Writer.new(@graph)
  end

  def ex
    @ex
  end

  def xsd
    RubyRDF::Namespace::XSD
  end

  describe "export_node" do
    it "should export URI" do
      uri = ex::resource
      uri.should_receive(:to_ntriples)
      @it.export_node(uri)
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
      literal = RubyRDF::PlainLiteral.new("test")
      literal.should_receive(:to_ntriples)
      @it.export_node(literal)
    end

    it "should export TypedLiteral" do
      literal = 2.to_literal
      literal.should_receive(:to_ntriples)
      @it.export_node(literal)
    end
  end
end
