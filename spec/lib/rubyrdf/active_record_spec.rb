require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

# Add the following to your .autotest file to stop autospec from an infinite loop
#
# Autotest.add_hook :initialize do |at|
#   at.add_exception("graph.db")
# end
describe RubyRDF::ActiveRecord do
  def ex
    @ex ||= RubyRDF::Namespace.new("http://example.com/")
  end

  def xsd
    @xsd ||= RubyRDF::Namespace::XSD
  end

  before(:all) do
    File.delete("graph.db") if File.exists?("graph.db")

    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "graph.db")
    conn = ActiveRecord::Base.connection
    conn.create_table(:graphs){}

    conn.create_table(:statements) do |t|
      t.integer :subject_id, :predicate_id, :object_id
      t.string :subject_type, :predicate_type, :object_type
    end

    conn.create_table(:graphs_statements, :id => false) do |t|
      t.integer :graph_id, :statement_id
    end

    conn.create_table(:uri_nodes) do |t|
      t.string :uri
    end

    conn.create_table(:plain_literals) do |t|
      t.string :lexical_form, :language_tag
    end

    conn.create_table(:typed_literals) do |t|
      t.string :lexical_form, :datatype_uri
    end

    conn.create_table(:b_nodes){}
  end

  before do
    RubyRDF::ActiveRecord::Graph.destroy_all
    RubyRDF::ActiveRecord::URINode.destroy_all
    RubyRDF::ActiveRecord::PlainLiteral.destroy_all
    RubyRDF::ActiveRecord::TypedLiteral.destroy_all
    RubyRDF::ActiveRecord::BNode.destroy_all
    @it = RubyRDF::ActiveRecord.new
  end

  describe "add" do
    it "should create AR objects" do
      @it.add(:a, ex::pred, 2.to_literal)
      @it.add(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))

      RubyRDF::ActiveRecord::BNode.count.should == 1
      @bnode = RubyRDF::ActiveRecord::BNode.find(:first)
      @bnode.should_not be_nil

      RubyRDF::ActiveRecord::URINode.count.should == 1
      @uri = RubyRDF::ActiveRecord::URINode.find_by_uri(ex::pred.uri)
      @uri.should_not be_nil

      RubyRDF::ActiveRecord::TypedLiteral.count.should == 1
      @typed_literal = RubyRDF::ActiveRecord::TypedLiteral.find_by_lexical_form_and_datatype_uri(2.to_literal.lexical_form,
                                                                                                 2.to_literal.datatype_uri.uri)
      @typed_literal.should_not be_nil

      RubyRDF::ActiveRecord::PlainLiteral.count.should == 1
      @plain_literal = RubyRDF::ActiveRecord::PlainLiteral.find_by_lexical_form_and_language_tag("test",
                                                                                                 "en")
      @plain_literal.should_not be_nil

      RubyRDF::ActiveRecord::Statement.count.should == 2
      RubyRDF::ActiveRecord::Statement.
        find(:first,
             :conditions => ['subject_id = ? and '+
                             'subject_type = ? and ' +
                             'predicate_id = ? and ' +
                             'predicate_type = ? and ' +
                             'object_id = ? and ' +
                             'object_type = ?',
                             @bnode.id,
                             @bnode.class.to_s,
                             @uri.id,
                             @uri.class.to_s,
                             @typed_literal.id,
                             @typed_literal.class.to_s
                            ]).should_not be_nil

      RubyRDF::ActiveRecord::Statement.
        find(:first,
             :conditions => ['subject_id = ? and '+
                             'subject_type = ? and ' +
                             'predicate_id = ? and ' +
                             'predicate_type = ? and ' +
                             'object_id = ? and ' +
                             'object_type = ?',
                             @bnode.id,
                             @bnode.class.to_s,
                             @uri.id,
                             @uri.class.to_s,
                             @plain_literal.id,
                             @plain_literal.class.to_s
                            ]).should_not be_nil
    end
  end

  describe "delete" do
    it "should remove statements from graph" do
      @it.add(:a, ex::pred, 2.to_literal)
      @it.add(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      @it.delete(:a, ex::pred, 2.to_literal)
      @it.delete(:a, ex::pred, RubyRDF::PlainLiteral.new("test", "en"))
      @it.size.should == 0
    end
  end
end
