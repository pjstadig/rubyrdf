require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::MemoryGraph, "without statements" do
  before do
    @ex = RubyRDF::Namespace.new('http://example.org/')
    @it = RubyRDF::MemoryGraph.new
  end

  def ex
    @ex
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
    @ex = RubyRDF::Namespace.new('http://example.org/')
    @it = RubyRDF::MemoryGraph.new(RubyRDF::Statement.new(ex::a, ex::b, ex::c),
                                   RubyRDF::Statement.new(ex::d, ex::e, ex::f))
  end

  def ex
    @ex
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

  describe "query" do
    it "should match bnodes" do
      @it.add(:a, ex::prop, ex::obj)
      @it.add(:b, ex::prop, ex::obj)
      @it.add(:b, ex::prop2, ex::obj)

      result = @it.query(RubyRDF::Query.new do |q|
                           q.where(:a, ex::prop, ex::obj)
                           q.where(:a, ex::prop2, ex::obj)
                         end)
      result.size.should == 1
      result[0][:a].should == :b
    end

    it "should be nil" do
      @it.add(:a, ex::prop, ex::obj)
      @it.add(:a, ex::prop, ex::obj)

      result = @it.query(RubyRDF::Query.new do |q|
                           q.select(:a)
                           q.where(:a, ex::prop, ex::obj)
                           q.where(:a, ex::prop2, ex::obj)
                         end)
      result.should be_nil
    end

    it "should be empty" do
      @it.add(ex::sub, ex::prop, ex::obj)

      result = @it.query(RubyRDF::Query.new do |q|
                           q.where(ex::sub, ex::prop, ex::obj)
                         end)
      result.should_not be_nil
      result.should be_empty
    end

    it "should filter" do
      @it.add(ex::sub, ex::prop, ex::obj)
      @it.add(ex::sub, ex::prop, 2.to_literal)

      result = @it.query(RubyRDF::Query.new do |q|
                           q.where(ex::sub, ex::prop, :a)
                           q.filter do |b|
                             RubyRDF.literal?(b[:a])
                           end
                         end)
      result.size.should == 1
      result[0][:a].should == 2.to_literal
    end
  end
end
