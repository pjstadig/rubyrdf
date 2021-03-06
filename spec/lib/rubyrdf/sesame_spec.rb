require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::Sesame do
  before do
    @ex = RubyRDF::Namespace.new('http://example.org/')
    @graph = RubyRDF::Sesame.new('http://localhost:8180/openrdf-sesame', 'test')
    @graph.delete_all
  end

  def ex
    @ex
  end

  describe 'initialize' do
    it "should assign host" do
      @graph.host.should == 'localhost'
    end

    it "should assign port" do
      @graph.port.should == 8180
    end

    it "should assign path" do
      @graph.path.should == '/openrdf-sesame'
    end

    it "should assign repository" do
      @graph.repository.should == 'test'
    end
  end

  describe "each" do
    it "should iterate each statement" do
      s1 = RubyRDF::Statement.new(ex::a, ex::b, ex::c)
      s2 = RubyRDF::Statement.new(ex::a, ex::b, ex::d)
      expected = [s1, s2]
      @graph.add_all(*expected)
      @graph.each{|s| expected.delete(s).should be_true}
      expected.should be_empty
    end
  end

  describe "clear" do
    it "should not call delete" do
      @graph.add(ex::sub, ex::pred, ex::obj)
      @graph.should_not_receive(:delete)
      @graph.clear
    end
  end

  it "should be writable" do
    @graph.should be_writable
  end

  it "should be empty" do
    @graph.should be_empty
  end

  it "should add a statement" do
    @graph.add(ex::sub, ex::pred, ex::obj)
    @graph.size.should == 1
  end

  it "should import data" do
    @graph.import(StringIO.new(<<-ENDL), :format => :ntriples)
      <#{ex::a}> <#{ex::b}> <#{ex::c}>.
      <#{ex::d}> <#{ex::b}> <#{ex::e}>.
    ENDL
    @graph.size.should == 2
    @graph.include?([ex::a, ex::b, ex::c]).should be_true
    @graph.include?([ex::d, ex::b, ex::e]).should be_true
  end

  it "should delete statement" do
    @graph.add(ex::sub, ex::pred, ex::obj)
    @graph.delete(ex::sub, ex::pred, ex::obj)
    @graph.should be_empty
  end

  it "should delete statement with URI that includes query" do
    s = RubyRDF::Statement.new(Addressable::URI.parse("http://example.org/q?abc=1&def=2"),
                               ex::pred,
                               ex::obj)
    @graph.add(s)
    @graph.should_not be_empty
    @graph.delete(s)
    @graph.should be_empty
  end

  it "should execute SPARQL select query" do
    @graph.add(ex::a, ex::b, RubyRDF::PlainLiteral.new('test'))
    @graph.add(ex::d, ex::b, RubyRDF::PlainLiteral.new('test', 'en'))
    @graph.add(ex::d, ex::b, RubyRDF::TypedLiteral.new('test', ex::a))
    @graph.add(ex::d, ex::b, ex::e)
    @graph.add(ex::d, ex::b, Object.new)

    result = @graph.select("SELECT ?y WHERE { ?x <#{ex::b}> ?y . }")
    result.size.should == 5
    result.any?{|r| r['y'] == RubyRDF::PlainLiteral.new('test')}.should be_true
    result.any?{|r| r['y'] == RubyRDF::PlainLiteral.new('test', 'en')}.should be_true
    result.any?{|r| r['y'] == RubyRDF::TypedLiteral.new('test', ex::a)}.should be_true
    result.any?{|r| r['y'] == ex::e}.should be_true
    result.any?{|r| RubyRDF.bnode?(r['y']) }.should be_true
  end

  it "should execute SPARQL select query with empty result" do
    @graph.select("SELECT ?x WHERE {?x <#{ex::nothing}> _:bn2 . }").should be_empty
  end

  it "should execute SPARQL ask query" do
    @graph.add(ex::sub, ex::pred, ex::obj)
    @graph.ask("ask { <#{ex::sub}> <#{ex::pred}> <#{ex::obj}> }").should be_true
  end

  it "should include statement" do
    @graph.add(ex::sub, ex::pred, ex::obj)
    @graph.include?(ex::sub, ex::pred, ex::obj).should be_true
  end

  it "should clear graph" do
    @graph.add(ex::sub, ex::pred, ex::obj)
    @graph.delete_all

    @graph.should be_empty
  end

  it "should commit a transaction" do
    stmt1 = RubyRDF::Statement.new(ex::sub, ex::pred1, RubyRDF::PlainLiteral.new('plainLiteral', 'en'))
    stmt2 = RubyRDF::Statement.new(Object.new, ex::pred2, RubyRDF::TypedLiteral.new('plainLiteral', ex::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.delete(stmt1)
    end

    @graph.include?(stmt2).should be_true
    @graph.include?(stmt1).should be_false
  end

  it "should commit in the middle of a transaction" do
    stmt1 = RubyRDF::Statement.new(ex::sub, ex::pred1, RubyRDF::PlainLiteral.new('plainLiteral', 'en'))
    stmt2 = RubyRDF::Statement.new(Object.new, ex::pred2, RubyRDF::TypedLiteral.new('plainLiteral', ex::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.commit
      t.delete(stmt1)
      t.rollback
    end

    @graph.include?(stmt1).should be_true
    @graph.include?(stmt2).should be_true
  end

  it "should accept an empty transaction" do
    @graph.transaction do |t|
    end
  end

  it "should rollback a transaction" do
    stmt1 = RubyRDF::Statement.new(ex::sub, ex::pred1, RubyRDF::PlainLiteral.new('plainLiteral', 'en'))
    stmt2 = RubyRDF::Statement.new(Object.new, ex::pred2, RubyRDF::TypedLiteral.new('plainLiteral', ex::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.delete(stmt1)
      t.rollback
    end

    @graph.include?(stmt1).should be_true
    @graph.include?(stmt2).should be_false
  end

  it "should rollback a transaction on an error" do
    stmt1 = RubyRDF::Statement.new(ex::sub, ex::pred1, RubyRDF::PlainLiteral.new('plainLiteral', 'en'))
    stmt2 = RubyRDF::Statement.new(Object.new, ex::pred2, RubyRDF::TypedLiteral.new('plainLiteral', ex::datatype))
    @graph.add(stmt1)
    begin
      @graph.transaction do |t|
        t.add(stmt2)
        t.delete(stmt1)
        throw "test"
      end
      fail "Should rethrow exception"
    rescue
    end

    @graph.include?(stmt1).should be_true
    @graph.include?(stmt2).should be_false
  end

  it "should rollback in the middle of a transaction" do
    stmt1 = RubyRDF::Statement.new(ex::sub, ex::pred1, RubyRDF::PlainLiteral.new('plainLiteral', 'en'))
    stmt2 = RubyRDF::Statement.new(Object.new, ex::pred2, RubyRDF::TypedLiteral.new('plainLiteral', ex::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.rollback
      t.delete(stmt1)
    end

    @graph.include?(stmt1).should be_false
    @graph.include?(stmt2).should be_false
  end
end
