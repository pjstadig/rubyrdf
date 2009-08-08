require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::Statement do
  def rdf
    RubyRDF::Namespace::RDF
  end

  before do
    @it = RubyRDF::Statement.new(rdf::subject, rdf::type, rdf::Property)
  end

  describe "#initialize" do
    it "should raise InvalidStatementError with literal predicate" do
      lambda {
        RubyRDF::Statement.new(rdf::subject, 2.to_literal, rdf::Property)
      }.should raise_error(RubyRDF::InvalidStatementError)
    end

    it "should raise InvalidStatementError with blank node predicate" do
      lambda {
        RubyRDF::Statement.new(rdf::subject, Object.new, rdf::Property)
      }.should raise_error(RubyRDF::InvalidStatementError)
    end

    it "should assign subject" do
      @it.subject.should == rdf::subject
    end

    it "should assign predicate" do
      @it.predicate.should == rdf::type
    end

    it "should assign object" do
      @it.object.should == rdf::Property
    end
  end

  describe "#==" do
    it 'should be equal with same subject, predicate, object' do
      @it.should == RubyRDF::Statement.new(rdf::subject, rdf::type, rdf::Property)
    end

    it 'should be equal to triple with same subject, predicate, object' do
      @it.should == [rdf::subject, rdf::type, rdf::Property]
    end

    it 'should not be equal with same predicate and object but different subject' do
      @it.should_not == RubyRDF::Statement.new(rdf::different, rdf::type, rdf::Property)
    end

    it 'should not be equal with same subject and object but different predicate' do
      @it.should_not == RubyRDF::Statement.new(rdf::subject, rdf::different, rdf::Property)
    end

    it 'should not be equal with same subject and predicate but different object' do
      @it.should_not == RubyRDF::Statement.new(rdf::subject, rdf::type, rdf::different)
    end

    it 'should not be equal to nil' do
      @it.should_not == nil
    end

    it 'should not be equal to non-Statement' do
      @it.should_not == Object.new
    end
  end

  it 'should alias #== as #eql?' do
    @it.class.instance_method(:eql?).should == @it.class.instance_method(:==)
  end

  describe "#hash" do
    it 'should be equal with same subject, predicate, and object' do
      @it.hash.should == RubyRDF::Statement.new(rdf::subject, rdf::type, rdf::Property).hash
    end

    it 'should not be equal with same predicate and object but different subject' do
      @it.hash.should_not == RubyRDF::Statement.new(rdf::different, rdf::type, rdf::Property).hash
    end

    it 'should not be equal with same subject and object but different predicate' do
      @it.hash.should_not == RubyRDF::Statement.new(rdf::subject, rdf::different, rdf::Property).hash
    end

    it 'should not be equal with same subject and predicate but different object' do
      @it.hash.should_not == RubyRDF::Statement.new(rdf::subject, rdf::type, rdf::different).hash
    end
  end

  it 'should return self for to_statement' do
    @it.to_statement.should equal(@it)
  end

  it 'should return array of subject, predicate, object for to_triple' do
    @it.to_triple.should == [@it.subject, @it.predicate, @it.object]
  end

  describe "to_ntriples" do
    it "should return an NTriples export" do
      @it.to_ntriples.should == "<#{rdf::subject}> <#{rdf::type}> <#{rdf::Property}>.\n"
    end
  end

  describe "inspect" do
    it "should use NTriples export" do
      @it.inspect.should == "#<RubyRDF::Statement #{@it.to_ntriples.strip.chomp('.')}>"
    end
  end
end

describe "Array#to_statement" do
  def rdf
    RubyRDF::Namespace::RDF
  end

  it 'should raise InvalidStatementError for two elements' do
    lambda{
      [rdf::subject, rdf::type].to_statement
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should raise InvalidStatementError for four elements' do
    lambda{
      [rdf::subject, rdf::type, rdf::Property, rdf::Property].to_statement
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should call to_statement on one element' do
    stmt = mock("statement")
    stmt.should_receive(:to_statement)
    [stmt].to_statement
  end

  it 'should call Statement.new on three elements' do
    RubyRDF::Statement.should_receive(:new).with(rdf::subject, rdf::type, rdf::Property)
    [rdf::subject, rdf::type, rdf::Property].to_statement
  end
end

describe "Array#to_triple" do
  def rdf
    RubyRDF::Namespace::RDF
  end

  it 'should raise InvalidStatementError for two elements' do
    lambda{
      [rdf::subject, rdf::type].to_triple
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should raise InvalidStatementError for four elements' do
    lambda{
      [rdf::subject, rdf::type, rdf::Property, rdf::Property].to_triple
    }.should raise_error(RubyRDF::InvalidStatementError)
  end

  it 'should return array for three elements' do
    [rdf::subject, rdf::type, rdf::Property].to_triple.should == [rdf::subject, rdf::type, rdf::Property]
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
    [rdf::subject, predicate, rdf::Property].to_triple
  end

  it 'should try to convert object to URI' do
    object = mock("object")
    object.should_receive(:respond_to?).with(:to_ary).and_return(false)
    object.should_receive(:respond_to?).with(:to_uri).and_return(true)
    object.should_receive(:to_uri)
    [rdf::subject, rdf::type, object].to_triple
  end

  it 'should try to convert object to Literal' do
    object = mock("object")
    object.should_receive(:respond_to?).with(:to_ary).and_return(false)
    object.should_receive(:respond_to?).with(:to_uri).and_return(false)
    object.should_receive(:respond_to?).with(:to_literal).and_return(true)
    object.should_receive(:to_literal)
    [rdf::subject, rdf::type, object].to_triple
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
