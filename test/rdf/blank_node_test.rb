require File.dirname(__FILE__) + '/../test_helper.rb'

class RDF::BlankNodeTest < Test::Unit::TestCase
  def test_should_initialize_name
    assert_equal 'test', RDF::BlankNode.new('test').name
  end
  
  def test_should_generate_name
    assert_not_nil RDF::BlankNode.new.name
  end
  
  def test_should_export_to_ntriples_format
    assert_equal '_:test', RDF::BlankNode.new('test').to_ntriples
    assert_equal '_:test', RDF::BlankNode.new('test').to_s
  end
end