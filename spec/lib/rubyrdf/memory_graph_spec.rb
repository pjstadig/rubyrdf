require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::MemoryGraph, "without statements" do
  before do
    RubyRDF::Namespaces.register(:ex => 'http://example.com/')
    @it = RubyRDF::MemoryGraph.new
  end

  def ex
    RubyRDF::Namespaces.ex
  end

  it 'should be writable' do
    @it.should be_writable
  end

  it 'should have a size of zero' do
    @it.size.should == 0
  end

  it 'should add a statement' do
    @it.add(ex::a, ex::b, ex::c)
    @it.should be_include(ex::a, ex::b, ex::c)
  end
end

describe RubyRDF::MemoryGraph, "with statements" do
  before do
    RubyRDF::Namespaces.register(:ex => 'http://example.com/')
    @it = RubyRDF::MemoryGraph.new(RubyRDF::Statement.new(ex::a, ex::b, ex::c),
                                   RubyRDF::Statement.new(ex::d, ex::e, ex::f))
  end

  def ex
    RubyRDF::Namespaces.ex
  end

  describe "size" do
    it 'should be 2' do
      @it.size.should == 2
    end
  end

  describe "each" do
    it 'should iterate over each statement' do
      @it.each do |s|
        [RubyRDF::Statement.new(ex::a, ex::b, ex::c),
         RubyRDF::Statement.new(ex::d, ex::e, ex::f)].should be_include(s)
      end
    end
  end

  describe "delete" do
    it 'should delete a statement' do
      @it.delete(ex::a, ex::b, ex::c).should be_true
      @it.include?(ex::a, ex::b, ex::c).should_not be_true
    end
  end

  it 'should return a single statement graph from match' do
    g = @it.match(ex::a, ex::b, ex::c)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 1
    g.should be_include(ex::a, ex::b, ex::c)
  end

  it 'should return an empty graph from match' do
    g = @it.match(ex::a, ex::b, ex::d)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 0
  end

  it 'should return a copy from match' do
    g = @it.match(nil, nil, nil)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 2
    g.should be_include(ex::a, ex::b, ex::c)
    g.should be_include(ex::d, ex::e, ex::f)
  end

  it 'should return a match from subject' do
    g = @it.match(ex::a, nil, nil)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 1
    g.should be_include(ex::a, ex::b, ex::c)
  end

  it 'should return a match from subject and predicate' do
    g = @it.match(ex::a, ex::b, nil)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 1
    g.should be_include(ex::a, ex::b, ex::c)
  end

  it 'should return an empty match from subject and predicate' do
    g = @it.match(:a, :a, nil)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 0
  end

  it 'should return an empty match from an invalid statement' do
    g = @it.match(2.to_literal, 2.to_literal, 2.to_literal)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 0
  end

  it 'should return an empty match from four arguments' do
    g = @it.match(2.to_literal, 2.to_literal, 2.to_literal, 2.to_literal)
    g.is_a?(RubyRDF::Graph).should be_true
    g.size.should == 0
  end
end
