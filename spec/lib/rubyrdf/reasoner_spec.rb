require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::Reasoner do
  EX = RubyRDF::Namespace.new("http://example.org/")
  R = RubyRDF::Namespace::RDF

  before do
    @graph = RubyRDF::MemoryGraph.new
    @reasoner = RubyRDF::Reasoner.new(@graph,[])
  end

  describe "forward_chain" do
    it "should reason" do
      @graph.add(EX::sub, R::type, EX::subclass)
      @graph.add(EX::subclass, R::subclassOf, EX::class)
      @reasoner.rules << RubyRDF::Reasoner::Rule.new do |r|
        r.condition(:a, R::type, :b)
        r.condition(:b, R::subclassOf, :c)
        r.conclusion(:a, R::type, :c)
      end

      @reasoner.forward_chain
      @graph.include?(EX::sub, R::type, EX::class).should be_true
    end
  end
end
