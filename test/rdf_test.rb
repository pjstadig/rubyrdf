require File.dirname(__FILE__) + '/test_helper.rb'

class RDFTest < Test::Unit::TestCase
  def setup
    RDF.unregister_all!
  end
  
  def test_should_register_defaults
    assert_equal 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', RDF.prefix(:rdf)
    assert_equal 'http://www.w3.org/2001/XMLSchema#', RDF.prefix(:xsd)
    assert_equal 'http://www.w3.org/2000/01/rdf-schema#', RDF.prefix(:rdfs)
    assert_equal 'http://www.w3.org/2002/07/owl#', RDF.prefix(:owl)
  end
  
  def test_should_not_unregister_defaults
    RDF.unregister_all!
    assert_equal 'http://www.w3.org/1999/02/22-rdf-syntax-ns#', RDF.prefix(:rdf)
    assert_equal 'http://www.w3.org/2001/XMLSchema#', RDF.prefix(:xsd)
    assert_equal 'http://www.w3.org/2000/01/rdf-schema#', RDF.prefix(:rdfs)
    assert_equal 'http://www.w3.org/2002/07/owl#', RDF.prefix(:owl)
  end
  
  def test_should_unregister
    RDF.register(:ps => 'http://paul.stadig.name/',
                 :ex => 'http://example.com/')
    RDF.unregister(:ps, :ex)
    assert !RDF.registered?(:ps)
    assert !RDF.registered?(:ex)
  end
  
  def test_should_unregister_all
    RDF.register(:ps => 'http://paul.stadig.name/',
                 :ex => 'http://example.com/')
    RDF.unregister_all!
    assert !RDF.registered?(:ps)
    assert !RDF.registered?(:ex)
  end
  
  def test_should_register
    RDF.register(:ps => 'http://paul.stadig.name/',
                 'ex' => 'http://example.com/')
    assert RDF.registered?(:ps)
    assert RDF.registered?(:ex)
  end
  
  def test_should_expand_uri
    RDF.register(:ex => 'http://example.com/')
    assert_equal 'http://example.com/test', RDF.expand_uri(:ex, 'test')
  end
  
  def test_should_expand_node
    RDF.register(:ex => 'http://example.com/')
    node = RDF::URINode.new('http://example.com/test')
    assert_equal node, RDF.expand_node(:ex, 'test')
    assert_equal node, RDF[:ex]::test
    assert_equal node, RDF[:ex].test
    assert_equal node, RDF[:ex]['test']
    assert_equal node, RDF[:ex][:test]
    assert_equal node, RDF['ex'][:test]
  end
end