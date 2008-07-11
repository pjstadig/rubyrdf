require File.dirname(__FILE__) + '/../test_helper.rb'

class RDF::URINodeTest < Test::Unit::TestCase
  def test_should_initialize_uri
    assert_equal 'http://stadig.name/', RDF::URINode.new('http://stadig.name/').uri
  end
  
  def test_should_normalize_uri
    assert_equal [0x03a9].pack('U'), RDF::URINode.new([0x2126].pack('U')).uri
  end
  
  def test_should_export_to_ntriples_format
    assert_equal '<http://stadig.name/>', RDF::URINode.new('http://stadig.name/').to_ntriples
    assert_equal '<http://stadig.name/>', RDF::URINode.new('http://stadig.name/').to_s
    assert_equal '<http://stadig.name/\u0008\U00010000\t\n\r\"\\\\>',
                 RDF::URINode.new('http://stadig.name/' + [0x8, 0x10000, 0x9, 0xa, 0xd, 0x22, 0x5c].pack('U*')).to_ntriples
  end
  
  def test_should_be_eq
    node = RDF::URINode.new('http://stadig.name/')
    assert node == RDF::URINode.new(node.uri)
  end
  
  def test_should_not_be_eq
    node = RDF::URINode.new('http://stadig.name/')
    assert node != nil
    assert node != RDF::URINode.new(node.uri + 'test')
  end
  
  def test_should_be_eql
    node = RDF::URINode.new('http://stadig.name/')
    assert node.eql?(RDF::URINode.new(node.uri))
  end
  
  def test_should_not_be_eql
    node = RDF::URINode.new('http://stadig.name/')
    assert !node.eql?(nil)
    assert !node.eql?(RDF::URINode.new(node.uri + 'test'))
  end
  
  def test_should_have_same_hash
    node = RDF::URINode.new('http://stadig.name/')
    assert node.hash == RDF::URINode.new(node.uri).hash
  end
  
  def test_should_be_node
    node = RDF::URINode.new('http://stadig.name/')
    
    assert node.uri_node?
    assert node.resource?
    assert node.node?
  end
end