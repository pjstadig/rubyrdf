module RDFXMLHelper
  def rdf
    RubyRDF::Namespace::RDF
  end

  def xsd
    RubyRDF::Namespace::XSD
  end

  def test_file_path(name)
    File.join(File.dirname(__FILE__), %w[.. fixtures], name)
  end

  def open_test_file(name)
    File.open(test_file_path(name), 'r') do |f|
      yield f
    end
  end

  def rdfxml_triples(name)
    open_test_file(name) do |f|
      RubyRDF::RDFXML::Reader.new(f, :base_uri => "http://www.w3.org/2000/10/rdf-tests/rdfcore/#{name}").each do |s|
        yield s
      end
    end
  end

  def ntriples_triples(name)
    open_test_file(name) do |f|
      RubyRDF::NTriples::Reader.new(f).each do |s|
        yield s
      end
    end
  end

  def execute_w3c_parser_test(name)
    actual = RubyRDF::MemoryGraph.new
    open_test_file("w3c/#{name}.rdf") do |f|
      actual.import(f, :format => :rdfxml, :base_uri => "http://www.w3.org/2000/10/rdf-tests/rdfcore/#{name}.rdf")
    end

    query = RubyRDF::Query.new do |q|
      ntriples_triples("w3c/#{name}.nt") do |s|
        q.where(s)
      end
    end

    if query.where.any?
      actual.to_a.should == query.where if actual.query(query).nil?
    else
      actual.should be_empty
    end
  end

  def execute_w3c_error_test(name)
    lambda {
      open_test_file("w3c/#{name}.rdf") do |f|
        RubyRDF::MemoryGraph.new.import(f, :format => :rdfxml)
      end
    }.should raise_error(RubyRDF::RDFXML::SyntaxError)
  end
end
