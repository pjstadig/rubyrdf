require File.dirname(__FILE__) + '/../test_helper.rb'

class RDF::TypedLiteralNodeTest < Test::Unit::TestCase
  def test_should_initialize_lexical_form_and_datatype_uri
    node = RDF::TypedLiteralNode.new('test', 'http://stadig.name/')
    assert_equal 'test', node.lexical_form
    assert_equal 'http://stadig.name/', node.datatype_uri
  end
  
  def test_should_be_eq
    assert RDF::TypedLiteralNode.new('test', 'http://stadig.name/') ==
           RDF::TypedLiteralNode.new('test', 'http://stadig.name/')
  end
  
  def test_should_not_be_eq
    assert RDF::TypedLiteralNode.new('test', 'http://stadig.name/') != 
           nil
    assert RDF::TypedLiteralNode.new('test', 'http://stadig.name/') !=
           RDF::TypedLiteralNode.new('test2', 'http://stadig.name/')
    assert RDF::TypedLiteralNode.new('test', 'http://stadig.name/') !=
           RDF::TypedLiteralNode.new('test', 'http://example.com/')
  end
  
  def test_should_be_eql
    assert RDF::TypedLiteralNode.new('test', 'http://stadig.name/').eql?(
      RDF::TypedLiteralNode.new('test', 'http://stadig.name/'))
  end
  
  def test_should_not_be_eql
    assert !RDF::TypedLiteralNode.new('test', 'http://stadig.name/').eql?(nil)
    assert !RDF::TypedLiteralNode.new('test', 'http://stadig.name/').eql?(
      RDF::TypedLiteralNode.new('test2', 'http://stadig.name/'))
    assert !RDF::TypedLiteralNode.new('test', 'http://stadig.name/').eql?(
      RDF::TypedLiteralNode.new('test', 'http://example.com/'))
  end
  
  def test_should_have_same_hash
    assert_equal RDF::TypedLiteralNode.new('test', 'http://stadig.name/').hash,
                 RDF::TypedLiteralNode.new('test', 'http://stadig.name/').hash
  end
  
  def test_should_export_to_ntriples_format
    assert_equal '"test"^^<http://stadig.name/>', RDF::TypedLiteralNode.new('test', 'http://stadig.name/').to_ntriples
    assert_equal '"\u0008\U00010000\t\n\r\"\\\\"^^<\u0008\U00010000\t\n\r\"\\\\>',
                 RDF::TypedLiteralNode.new([0x8, 0x10000, 0x9, 0xa, 0xd, 0x22, 0x5c].pack('U*'), 
                                           [0x8, 0x10000, 0x9, 0xa, 0xd, 0x22, 0x5c].pack('U*')).to_ntriples
  end
end