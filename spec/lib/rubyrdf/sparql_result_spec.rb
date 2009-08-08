require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

describe RubyRDF::SparqlResult do
  before do
    @ex = RubyRDF::Namespace.new('http://example.org/')
  end

  def ex
    @ex
  end

  it "should preserve blank node identity" do
    result = RubyRDF::SparqlResult.new(<<-ENDL)
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

    result[1]['x'].should equal(result[0]['x'])
  end

  it "should parse uri node" do
    result = RubyRDF::SparqlResult.new(<<-ENDL)
      <?xml version='1.0' encoding='UTF-8'?>
      <sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
          <variable name='x'/>
        </head>
        <results>
          <result>
            <binding name='x'>
              <uri>http://example.org/a</uri>
            </binding>
          </result>
        </results>
      </sparql>
    ENDL

    result[0]['x'].should == ex::a
  end

  it "should parse plain literal node" do
    result = RubyRDF::SparqlResult.new(<<-ENDL)
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

    result[0]['x'].should == RubyRDF::PlainLiteral.new('test')
  end

  it "should parse plain literal node with a language tag" do
    result = RubyRDF::SparqlResult.new(<<-ENDL)
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

    result[0]['x'].should == RubyRDF::PlainLiteral.new('test', 'en')
  end

  it "should parse typed literal node" do
    result = RubyRDF::SparqlResult.new(<<-ENDL)
      <?xml version='1.0' encoding='UTF-8'?>
      <sparql xmlns='http://www.w3.org/2005/sparql-results#'>
        <head>
          <variable name='x'/>
        </head>
        <results>
          <result>
            <binding name='x'>
              <literal datatype='http://example.org/a'>test</literal>
            </binding>
          </result>
        </results>
      </sparql>
    ENDL

    result[0]['x'].should == RubyRDF::TypedLiteral.new('test', ex::a)
  end

  it "should validate data" do
    lambda {
      RubyRDF::SparqlResult.new('<test>')
    }.should raise_error(RubyRDF::SparqlResult::InvalidDocument)
  end
end
