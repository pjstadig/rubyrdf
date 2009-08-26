require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

# Add the following to your .autotest file to stop autospec from an infinite loop
#
# Autotest.add_hook :initialize do |at|
#   at.add_exception("graph.db")
# end
describe RubyRDF::ActiveRecord do
  include ActiveRecordHelper

  def ex
    @ex ||= RubyRDF::Namespace.new("http://example.com/")
  end

  def xsd
    @xsd ||= RubyRDF::Namespace::XSD
  end

  before(:all) do
    setup_db
  end

  before do
    reset_db
    @it = RubyRDF::ActiveRecord.new
  end

  describe "add" do
    it "should create Statement" do
      @it.add(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::Statement.count.should == 1
      @it.include?(:a, ex::pred, 2.to_literal).should be_true
    end

    it "should only create a Statement once" do
      @it.add(ex::sub, ex::pred, 2.to_literal)
      another = RubyRDF::ActiveRecord.new
      another.add(ex::sub, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::Statement.count.should == 1
    end

    it "should only add a Statement once" do
      @it.add(:a, ex::pred, 2.to_literal)
      @it.add(:a, ex::pred, 2.to_literal)
      @it.size.should == 1
      RubyRDF::ActiveRecord::Statement.count.should == 1
      @it.include?(:a, ex::pred, 2.to_literal).should be_true
    end

    it "should create URINode" do
      @it.add(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::URINode.count.should == 1
      RubyRDF::ActiveRecord::URINode.find_by_uri(ex::pred.uri).should_not be_nil
    end

    it "should create PlainLiteral" do
      @it.add(:a, ex::pred, RubyRDF::PlainLiteral.new("test"))
      RubyRDF::ActiveRecord::PlainLiteral.count.should == 1
      RubyRDF::ActiveRecord::PlainLiteral.find(:first,
                                               :conditions => {
                                                 :lexical_form => "test",
                                                 :language_tag => nil
                                               }).should_not be_nil
    end

    it "should create PlainLiteral with language tag" do
      @it.add(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      RubyRDF::ActiveRecord::PlainLiteral.count.should == 1
      RubyRDF::ActiveRecord::PlainLiteral.find(:first,
                                               :conditions => {
                                                 :lexical_form => "test",
                                                 :language_tag => "en"
                                               }).should_not be_nil
    end

    it "should create TypedLiteral" do
      @it.add(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::TypedLiteral.count.should == 1
      RubyRDF::ActiveRecord::TypedLiteral.find(:first,
                                               :conditions => {
                                                 :lexical_form => "2",
                                                 :datatype_uri => xsd::integer.uri
                                               }).should_not be_nil
    end

    it "should create BNode" do
      @it.add(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::BNode.count.should == 1
    end
  end

  describe "delete" do
    before do
      @it.add(:a, ex::pred, 2.to_literal)
    end

    it "should remove statement from graph" do
      @it.delete(:a, ex::pred, 2.to_literal)
      @it.size.should == 0
    end

    it "should destroy Statement" do
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::Statement.count.should == 0
    end

    it "should destroy URINode" do
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::URINode.count.should == 0
    end

    it "should destroy PlainLiteral" do
      @it.add(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      @it.delete(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      RubyRDF::ActiveRecord::PlainLiteral.count.should == 0
    end

    it "should destroy TypedLiteral" do
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::TypedLiteral.count.should == 0
    end

    it "should destroy BNode" do
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::BNode.count.should == 0
    end
  end

  describe "delete with statement in another graph" do
    before do
      @it.add(:a, ex::pred, 2.to_literal)
      @another = RubyRDF::ActiveRecord.new
      @another.add(:a, ex::pred, 2.to_literal)
    end

    it "should remove statement from graph" do
      @it.delete(:a, ex::pred, 2.to_literal)
      @it.size.should == 0
    end

    it "should not destroy Statement" do
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::Statement.count.should == 1
      @another.include?(:a, ex::pred, 2.to_literal).should be_true
    end
  end

  describe "delete with another statement" do
    before do
      @it.add(:a, ex::pred, 2.to_literal)
      @it.add(:b, ex::pred, 2.to_literal)
    end

    it "should not destroy URINode" do
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::URINode.count.should == 1
      RubyRDF::ActiveRecord::URINode.find_by_uri(ex::pred.uri).should_not be_nil
    end

    it "should not destroy PlainLiteral" do
      @it.add(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      @it.add(:b, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      @it.delete(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      RubyRDF::ActiveRecord::PlainLiteral.count.should == 1
      RubyRDF::ActiveRecord::PlainLiteral.find(:first,
                                               :conditions => {
                                                 :lexical_form => "test",
                                                 :language_tag => "en"
                                               }).should_not be_nil
    end

    it "should not destroy TypedLiteral" do
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::TypedLiteral.count.should == 1
      RubyRDF::ActiveRecord::TypedLiteral.find(:first,
                                               :conditions => {
                                                 :lexical_form => "2",
                                                 :datatype_uri => xsd::integer.uri
                                               }).should_not be_nil
    end

    it "should not destroy BNode" do
      @it.add(ex::sub, ex::pred, :a)
      @it.delete(:a, ex::pred, 2.to_literal)
      RubyRDF::ActiveRecord::BNode.count.should == 2
    end
  end

  describe "match" do
    before do
      reset_db
      @it = RubyRDF::ActiveRecord.new
      @it.add(:a, ex::pred, 2.to_literal)
      @it.add(:b, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
    end

    it "should match all statements" do
      g = @it.match(nil, nil, nil)
      g.size.should == 2
      g.include?(:a, ex::pred, 2.to_literal).should be_true
      g.include?(:b, ex::pred, RubyRDF::PlainLiteral.new("test", "en")).should be_true
    end

    it "should match statements" do
      g = @it.match(nil, ex::pred, nil)
      g.size.should == 2
      g.include?(:a, ex::pred, 2.to_literal).should be_true
      g.include?(:b, ex::pred, RubyRDF::PlainLiteral.new("test", "en")).should be_true
    end

    it "should match (not-bind) known BNode" do
      g = @it.match(:a, nil, nil)
      g.size.should == 1
      g.include?(:a, ex::pred, 2.to_literal).should be_true
    end

    it "should not match invalid statement" do
      g = @it.match(2.to_literal, nil, nil)
      g.size.should == 0
    end
  end
end
