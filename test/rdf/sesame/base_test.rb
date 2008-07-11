require File.dirname(__FILE__) + '/../../test_helper.rb'

class RDF::Sesame::BaseTest < Test::Unit::TestCase
  def setup
    @graph = RDF::Sesame::Base.new('http://localhost:8180/openrdf-sesame', 'test')
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
end