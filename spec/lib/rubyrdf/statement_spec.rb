require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::Statement do
  before do
    @it = RubyRDF::Statement.new(rdf::type, rdf::type, rdf::Property)
  end

  def rdf
    RubyRDF::Namespaces.rdf
  end

  it "should raise InvalidStatementError with literal subject" do
    lambda{
      RubyRDF::Statement.new(2.to_literal, rdf::type, rdf::Property)
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it "should raise InvalidStatementError with non-node subject" do
    lambda {
      RubyRDF::Statement.new(Object.new, rdf::type, rdf::Property)
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it "should raise InvalidStatementError with literal predicate" do
    lambda {
      RubyRDF::Statement.new(rdf::type, 2.to_literal, rdf::Property)
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it "should raise InvalidStatementError with blank node predicate" do
    lambda {
      RubyRDF::Statement.new(rdf::type, RubyRDF::BNode.new, rdf::Property)
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it "should raise InvalidStatementError with non-node predicate" do
    lambda {
      RubyRDF::Statement.new(rdf::type, Object.new, rdf::Property)
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it "should raise InvalidStatementError with non-node object" do
    lambda {
      RubyRDF::Statement.new(rdf::type, rdf::type, Object.new)
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should be equal with same subject, predicate, object' do
    @it.should == RubyRDF::Statement.new(rdf::type, rdf::type, rdf::Property)
  end

  it 'should not be equal with same predicate and object but different subject' do
    @it.should_not == RubyRDF::Statement.new(rdf::different, rdf::type, rdf::Property)
  end

  it 'should not be equal with same subject and object but different predicate' do
    @it.should_not == RubyRDF::Statement.new(rdf::type, rdf::different, rdf::Property)
  end

  it 'should not be equal with same subject and predicate but different object' do
    @it.should_not == RubyRDF::Statement.new(rdf::type, rdf::type, rdf::different)
  end

  it 'should not be equal to nil' do
    @it.should_not == nil
  end

  it 'should not be equal to non-Statement' do
    @it.should_not == Object.new
  end

  it 'should alias #== as #eql?' do
    @it.class.instance_method(:eql?).should == @it.class.instance_method(:==)
  end

  it 'should hash equal with same subject, predicate, and object' do
    @it.hash.should == RubyRDF::Statement.new(rdf::type, rdf::type, rdf::Property).hash
  end

  it 'should not hash equal with same predicate and object but different subject' do
    @it.hash.should_not == RubyRDF::Statement.new(rdf::different, rdf::type, rdf::Property).hash
  end

  it 'should not hash equal with same subject and object but different predicate' do
    @it.hash.should_not == RubyRDF::Statement.new(rdf::type, rdf::different, rdf::Property).hash
  end

  it 'should not hash equal with same subject and predicate but different object' do
    @it.hash.should_not == RubyRDF::Statement.new(rdf::type, rdf::type, rdf::different).hash
  end

  it 'should return self for to_statement' do
    @it.to_statement.should equal(@it)
  end

  it 'should return array of subject, predicate, object for to_triple' do
    @it.to_triple.should == [@it.subject, @it.predicate, @it.object]
  end
end

describe "Array#to_statement" do
  def rdf
    RubyRDF::Namespaces.rdf
  end

  it 'should raise InvalidStatementError for two elements' do
    lambda{
      [rdf::type, rdf::type].to_statement
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should raise InvalidStatementError for four elements' do
    lambda{
      [rdf::type, rdf::type, rdf::Property, rdf::Property].to_statement
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should call to_statement on one element' do
    stmt = mock("statement")
    stmt.should_receive(:to_statement)
    [stmt].to_statement
  end

  it 'should call Statement.new on three elements' do
    RubyRDF::Statement.should_receive(:new).with(rdf::type, rdf::type, rdf::Property)
    [rdf::type, rdf::type, rdf::Property].to_statement
  end
end

describe "Array#to_triple" do
  def rdf
    RubyRDF::Namespaces.rdf
  end

  it 'should raise InvalidStatementError for two elements' do
    lambda{
      [rdf::type, rdf::type].to_triple
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should raise InvalidStatementError for four elements' do
    lambda{
      [rdf::type, rdf::type, rdf::Property, rdf::Property].to_triple
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should return array for three elements' do
    [rdf::type, rdf::type, rdf::Property].to_triple.should == [rdf::type, rdf::type, rdf::Property]
  end

  it 'should call to_triple on one element' do
    stmt = mock("statement")
    stmt.should_receive(:to_triple)
    [stmt].to_triple
  end

  it 'should try to convert subject to URI' do
    subject = mock("subject")
    subject.should_receive(:respond_to?).with(:to_ary).and_return(false)
    subject.should_receive(:respond_to?).with(:to_uri).and_return(true)
    subject.should_receive(:to_uri)
    [subject, rdf::type, rdf::Property].to_triple
  end

  it 'should try to convert predicate to URI' do
    predicate = mock("predicate")
    predicate.should_receive(:respond_to?).with(:to_ary).and_return(false)
    predicate.should_receive(:respond_to?).with(:to_uri).and_return(true)
    predicate.should_receive(:to_uri)
    [rdf::type, predicate, rdf::Property].to_triple
  end

  it 'should try to convert object to URI' do
    object = mock("object")
    object.should_receive(:respond_to?).with(:to_ary).and_return(false)
    object.should_receive(:respond_to?).with(:to_uri).and_return(true)
    object.should_receive(:to_uri)
    [rdf::type, rdf::type, object].to_triple
  end

  it 'should try to convert object to Literal' do
    object = mock("object")
    object.should_receive(:respond_to?).with(:to_ary).and_return(false)
    object.should_receive(:respond_to?).with(:to_uri).and_return(false)
    object.should_receive(:respond_to?).with(:to_literal).and_return(true)
    object.should_receive(:to_literal)
    [rdf::type, rdf::type, object].to_triple
  end
end

describe "Object#to_statement" do
  it 'should raise InvalidStatementError' do
    lambda { Object.new.to_statement }.should raise_error(RubyRDF::InvalidStatementError)
  end
end

describe "Object#to_triple" do
  it 'should raise InvalidStatementError' do
    lambda { Object.new.to_triple }.should raise_error(RubyRDF::InvalidStatementError)
  end
end
