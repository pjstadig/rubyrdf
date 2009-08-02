require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::Graph do
  before do
    RubyRDF::Namespaces.register(:ex => 'http://example.com/')
    @it = RubyRDF::Graph.new
  end

  def ex
    RubyRDF::Namespaces.ex
  end

  describe 'add_all' do
    it 'should add all statements to graph' do
      @it.should_receive(:add).with(ex::a, ex::b, ex::c)
      @it.should_receive(:add).with(ex::d, ex::e, ex::f)

      @it.add_all([ex::a, ex::b, ex::c], [ex::d, ex::e, ex::f])
    end
  end

  describe 'delete_all' do
    it 'should delete all statements from graph' do
      stmt = RubyRDF::Statement.new(ex::a, ex::b, ex::c)
      stmt2 = RubyRDF::Statement.new(ex::d, ex::e, ex::f)
      @it.stub!(:writable?).and_return(true)
      @it.should_receive(:delete).with(stmt)
      @it.should_receive(:delete).with(stmt2)
      @it.should_receive(:each).and_yield(stmt).and_yield(stmt2)
      @it.delete_all
    end
  end

  describe 'variable?' do
    it 'should be true for a symbol' do
      @it.variable?(:x).should be_true
    end

    it 'should be true for an unknown BNode' do
      @it.stub!(:known?).and_return(false)
      @it.variable?(Object.new).should be_true
    end

    it 'should return false for a known BNode' do
      @it.stub!(:known?).and_return(true)
      @it.variable?(Object.new).should_not be_true
    end

    it 'should return false for anything else' do
      @it.variable?(ex::example).should_not be_true
      @it.variable?(2.to_literal).should_not be_true
    end
  end

  describe 'uri?' do
    it "should be true for Addressable::URI" do
      @it.uri?(ex::example).should be_true
    end

    it "should be false for PlainLiteral" do
      @it.uri?(RubyRDF::PlainLiteral.new('test')).should be_false
    end

    it "should be false for TypedLiteral" do
      @it.uri?(2.to_literal).should be_false
    end

    it "should be false for Object" do
      @it.uri?(Object.new).should be_false
    end
  end

  describe 'literal?' do
    it "should be true for PlainLiteral" do
      @it.literal?(RubyRDF::PlainLiteral.new('test')).should be_true
    end

    it "should be true for TypedLiteral" do
      @it.literal?(2.to_literal).should be_true
    end

    it "should be false for Addressable::URI" do
      @it.literal?(ex::example).should be_false
    end

    it "should be false for Object" do
      @it.literal?(Object.new).should be_false
    end
  end

  describe 'bnode?' do
    it "should be true for Object" do
      @it.bnode?(Object.new).should be_true
    end

    it "should be false for Addressable::URI" do
      @it.bnode?(ex::example).should be_false
    end

    it "should be false for PlainLiteral" do
      @it.bnode?(RubyRDF::PlainLiteral.new('test')).should be_false
    end

    it "should be false for TypedLiteral" do
      @it.bnode?(2.to_literal).should be_false
    end
  end
end
