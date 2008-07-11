require File.dirname(__FILE__) + '/../test_helper.rb'

class RDF::PlainLiteralNodeTest < Test::Unit::TestCase
  def test_should_initialize_lexical_form
    assert_equal 'test', RDF::PlainLiteralNode.new('test').lexical_form
  end
  
  def test_should_initialize_language_tag
    assert_nil RDF::PlainLiteralNode.new('test').language_tag
    assert_equal 'en', RDF::PlainLiteralNode.new('test', 'en').language_tag
  end
  
  def test_should_be_eq
    assert RDF::PlainLiteralNode.new('test', 'en') ==
           RDF::PlainLiteralNode.new('test', 'en')
    assert RDF::PlainLiteralNode.new('test') ==
           RDF::PlainLiteralNode.new('test')
  end
  
  def test_should_not_be_eq
    node = RDF::PlainLiteralNode.new('test', 'en')
    assert node != nil
    assert node != RDF::PlainLiteralNode.new('test')
    assert node != RDF::PlainLiteralNode.new('test2', 'en')
    assert node != RDF::PlainLiteralNode.new('test', 'fr')
  end
  
  def test_should_be_eql
    node = RDF::PlainLiteralNode.new('test', 'en')
    assert node.eql?(RDF::PlainLiteralNode.new('test', 'en'))
  end
  
  def test_should_not_be_eql
    node = RDF::PlainLiteralNode.new('test', 'en')
    assert !node.eql?(nil)
    assert !node.eql?(RDF::PlainLiteralNode.new('test'))
    assert !node.eql?(RDF::PlainLiteralNode.new('test2', 'en'))
    assert !node.eql?(RDF::PlainLiteralNode.new('test', 'fr'))
  end
  
  def test_should_have_same_hash
    assert_equal RDF::PlainLiteralNode.new('test').hash,
                 RDF::PlainLiteralNode.new('test').hash
    assert_equal RDF::PlainLiteralNode.new('test', 'en').hash,
                 RDF::PlainLiteralNode.new('test', 'en').hash
  end
  
  def test_should_export_to_ntriples_format
    assert_equal '"test"', RDF::PlainLiteralNode.new('test').to_ntriples
    assert_equal '"test"@en', RDF::PlainLiteralNode.new('test', 'en').to_ntriples
    assert_equal '"test"', RDF::PlainLiteralNode.new('test').to_s
    assert_equal '"\u0008\U00010000\t\n\r\"\\\\"@en',
                 RDF::PlainLiteralNode.new([0x8, 0x10000, 0x9, 0xa, 0xd, 0x22, 0x5c].pack('U*'), 'en').to_ntriples
  end
  
  def test_should_be_node
    node = RDF::PlainLiteralNode.new('test')
    
    assert node.plain_literal_node?
    assert node.literal_node?
    assert node.node?
  end
end