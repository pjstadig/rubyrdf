require File.dirname(__FILE__) + '/../test_helper.rb'

class RDF::SesameTest < Test::Unit::TestCase
  def setup
    @graph = RDF::Sesame.new('http://localhost:8180/openrdf-sesame', 'test')
    @graph.delete_all
    RDF::unregister_all!
    RDF::register(:ex => 'http://example.org/')
  end
  
  def test_should_initialize_address_port_path_and_repository
    assert_equal 'localhost', @graph.address
    assert_equal 8180, @graph.port
    assert_equal '/openrdf-sesame', @graph.path
    assert_equal 'test', @graph.repository
  end
  
  def test_should_be_empty
    assert @graph.empty?
  end
  
  def test_should_add_statement
    @graph.add(RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj)
    assert_equal 1, @graph.size
  end
  
  def test_should_import_data
    @graph.import(<<-ENDL, :ntriples)
      #{[RDF[:ex]::a, RDF[:ex]::b, RDF[:ex]::c].to_statement.to_ntriples}
      #{[RDF[:ex]::d, RDF[:ex]::b, RDF[:ex]::e].to_statement.to_ntriples}
    ENDL
    assert_equal 2, @graph.size
    assert @graph.include?([RDF[:ex]::a, RDF[:ex]::b, RDF[:ex]::c])
    assert @graph.include?([RDF[:ex]::d, RDF[:ex]::b, RDF[:ex]::e])
  end
  
  def test_should_delete_statement
    @graph.add(RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj)
    @graph.delete(RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj)
    assert @graph.empty?
  end
  
  def test_should_execute_select_query
    assert @graph.select("SELECT ?x WHERE {?x #{RDF[:ex]::nothing} _:bn2 . }").empty?
    
    @graph.add(RDF[:ex]::a, RDF[:ex]::b, RDF::PlainLiteralNode.new('test'))
    @graph.add(RDF[:ex]::d, RDF[:ex]::b, RDF::PlainLiteralNode.new('test', 'en'))
    @graph.add(RDF[:ex]::d, RDF[:ex]::b, RDF::TypedLiteralNode.new('test', RDF[:ex]::a.uri))
    @graph.add(RDF[:ex]::d, RDF[:ex]::b, RDF[:ex]::e)
    @graph.add(RDF[:ex]::d, RDF[:ex]::b, RDF::BlankNode.new)
    result = @graph.select("SELECT ?y WHERE {?x #{RDF[:ex]::b} ?y . }")
    assert_equal 5, result.size
    assert result.any?{|r| r['y'] == RDF::PlainLiteralNode.new('test')}
    assert result.any?{|r| r['y'] == RDF::PlainLiteralNode.new('test', 'en')}
    assert result.any?{|r| r['y'] == RDF::TypedLiteralNode.new('test', RDF[:ex]::a.uri)}
    assert result.any?{|r| r['y'] == RDF[:ex]::e}
    assert result.any?{|r| r['y'].blank_node?}
  end
  
  def test_should_execute_ask_query
    @graph.add(RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj)
    assert @graph.ask("ask { #{[RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj].to_statement.to_ntriples} }")
  end
  
  def test_should_include_statement
    @graph.add(RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj)
    assert @graph.include?(RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj)
  end
  
  def test_should_clear_graph
    @graph.add(RDF[:ex]::sub, RDF[:ex]::pred, RDF[:ex]::obj)
    @graph.delete_all
    
    assert @graph.empty?
  end
  
  def test_should_commit_transaction
    stmt1 = RDF::Statement.new(RDF[:ex]::sub, RDF[:ex]::pred1, RDF::PlainLiteralNode.new('plainLiteral', 'en'))
    stmt2 = RDF::Statement.new(RDF::BlankNode.new("test2"), RDF[:ex]::pred2, RDF::TypedLiteralNode.new('plainLiteral', RDF[:ex]::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.delete(stmt1)
    end
    
    assert @graph.include?(stmt2)
    assert !@graph.include?(stmt1)
  end
  
  def test_should_commit_in_middle_of_transaction
    stmt1 = RDF::Statement.new(RDF[:ex]::sub, RDF[:ex]::pred1, RDF::PlainLiteralNode.new('plainLiteral', 'en'))
    stmt2 = RDF::Statement.new(RDF::BlankNode.new("test2"), RDF[:ex]::pred2, RDF::TypedLiteralNode.new('plainLiteral', RDF[:ex]::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.commit
      t.delete(stmt1)
      t.rollback
    end
    
    assert @graph.include?(stmt1)
    assert @graph.include?(stmt2)
  end
  
  def test_should_accept_empty_transaction
    @graph.transaction do |t|
    end
  end
  
  def test_should_rollback_transaction
    stmt1 = RDF::Statement.new(RDF[:ex]::sub, RDF[:ex]::pred1, RDF::PlainLiteralNode.new('plainLiteral', 'en'))
    stmt2 = RDF::Statement.new(RDF::BlankNode.new("test2"), RDF[:ex]::pred2, RDF::TypedLiteralNode.new('plainLiteral', RDF[:ex]::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.delete(stmt1)
      t.rollback
    end
    
    assert @graph.include?(stmt1)
    assert !@graph.include?(stmt2)
  end
  
  def test_should_rollback_transaction_on_exception
    stmt1 = RDF::Statement.new(RDF[:ex]::sub, RDF[:ex]::pred1, RDF::PlainLiteralNode.new('plainLiteral', 'en'))
    stmt2 = RDF::Statement.new(RDF::BlankNode.new("test2"), RDF[:ex]::pred2, RDF::TypedLiteralNode.new('plainLiteral', RDF[:ex]::datatype))
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
    
    assert @graph.include?(stmt1)
    assert !@graph.include?(stmt2)
  end
  
  def test_should_rollback_in_middle_of_transaction
    stmt1 = RDF::Statement.new(RDF[:ex]::sub, RDF[:ex]::pred1, RDF::PlainLiteralNode.new('plainLiteral', 'en'))
    stmt2 = RDF::Statement.new(RDF::BlankNode.new("test2"), RDF[:ex]::pred2, RDF::TypedLiteralNode.new('plainLiteral', RDF[:ex]::datatype))
    @graph.add(stmt1)
    @graph.transaction do |t|
      t.add(stmt2)
      t.rollback
      t.delete(stmt1)
    end
    
    assert !@graph.include?(stmt1)
    assert !@graph.include?(stmt2)
  end
end