require File.dirname(__FILE__) + '/../test_helper.rb'

class RDF::SparqlResultTest < Test::Unit::TestCase
  def setup
    RDF.unregister_all!
    RDF.register(:ex => 'http://example.com/')
  end
  
  def test_should_preserve_blank_node_identity
    result = RDF::SparqlResult.new(<<-ENDL)
      <?xml version='1.0' encoding='UTF-8'?>
      <sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
          <variable name='x'/>
        </head>
        <results>
          <result>
            <binding name='x'>
              <bnode>bn1</bnode>
            </binding>
          </result>
          <result>
            <binding name='x'>
              <bnode>bn1</bnode>
            </binding>
          </result>
        </results>
      </sparql>
    ENDL
    
    assert_same result[0]['x'], result[1]['x']
  end
  
  def test_should_parse_uri_node
    result = RDF::SparqlResult.new(<<-ENDL)
      <?xml version='1.0' encoding='UTF-8'?>
      <sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
          <variable name='x'/>
        </head>
        <results>
          <result>
            <binding name='x'>
              <uri>http://example.com/a</uri>
            </binding>
          </result>
        </results>
      </sparql>
    ENDL
    
    assert_equal RDF[:ex]::a, result[0]['x']
  end
  
  def test_should_parse_plain_literal_node
    result = RDF::SparqlResult.new(<<-ENDL)
      <?xml version='1.0' encoding='UTF-8'?>
      <sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
          <variable name='x'/>
        </head>
        <results>
          <result>
            <binding name='x'>
              <literal>test</literal>
            </binding>
          </result>
        </results>
      </sparql>
    ENDL
    
    assert_equal RDF::PlainLiteralNode.new('test'), result[0]['x']
    
    result = RDF::SparqlResult.new(<<-ENDL)
      <?xml version='1.0' encoding='UTF-8'?>
      <sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
          <variable name='x'/>
        </head>
        <results>
          <result>
            <binding name='x'>
              <literal xml:lang='en'>test</literal>
            </binding>
          </result>
        </results>
      </sparql>
    ENDL
    
    assert_equal RDF::PlainLiteralNode.new('test', 'en'), result[0]['x']
  end
  
  def test_should_parse_typed_literal_node
    result = RDF::SparqlResult.new(<<-ENDL)
      <?xml version='1.0' encoding='UTF-8'?>
      <sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
          <variable name='x'/>
        </head>
        <results>
          <result>
            <binding name='x'>
              <literal datatype='http://example.com/a'>test</literal>
            </binding>
          </result>
        </results>
      </sparql>
    ENDL
    
    assert_equal RDF::TypedLiteralNode.new('test', 'http://example.com/a'), result[0]['x']
  end
  
  def test_should_validate_data
    assert_raises(RDF::SparqlResult::InvalidDocument) {
      RDF::SparqlResult.new('<test>')
    }
  end
end