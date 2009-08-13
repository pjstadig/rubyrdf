require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader do
  def rdf
    RubyRDF::Namespace::RDF
  end

  def xsd
    RubyRDF::Namespace::XSD
  end

  def test_file_path(name)
    File.join(File.dirname(__FILE__), %w[.. .. .. fixtures], name)
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

    if actual.query(query).nil?
      actual.to_a.should == query.where
    end
  end

  def execute_w3c_error_test(name)
    lambda {
      open_test_file("w3c/#{name}.rdf") do |f|
        RubyRDF::MemoryGraph.new.import(f, :format => :rdfxml)
      end
    }.should raise_error(RubyRDF::RDFXML::SyntaxError)
  end

  it "should pass amp-in-url/test001.rdf" do
    execute_w3c_parser_test('amp-in-url/test001')
  end

  it "should pass datatypes/test001.rdf" do
    execute_w3c_parser_test('datatypes/test001')
  end

  it "should pass datatypes/test002.rdf" do
    execute_w3c_parser_test('datatypes/test002')
  end

  it "should pass rdf-element-not-mandatory/test001.rdf" do
    execute_w3c_parser_test('rdf-element-not-mandatory/test001')
  end

  it "should pass rdfms-reification-required/test001.rdf" do
    execute_w3c_parser_test('rdfms-reification-required/test001')
  end

  it "should pass rdfms-uri-substructure/test001.rdf" do
    execute_w3c_parser_test('rdfms-uri-substructure/test001')
  end

  it "should pass rdfms-xmllang/test001.rdf" do
    execute_w3c_parser_test('rdfms-xmllang/test001')
  end

  it "should pass rdfms-xmllang/test002.rdf" do
    execute_w3c_parser_test('rdfms-xmllang/test002')
  end

  it "should pass rdfms-xmllang/test003.rdf" do
    execute_w3c_parser_test('rdfms-xmllang/test003')
  end

  it "should pass rdfms-xmllang/test004.rdf" do
    execute_w3c_parser_test('rdfms-xmllang/test004')
  end

  it "should pass rdfms-xmllang/test005.rdf" do
    execute_w3c_parser_test('rdfms-xmllang/test005')
  end

  it "should pass rdfms-xmllang/test006.rdf" do
    execute_w3c_parser_test('rdfms-xmllang/test006')
  end

  it "should pass unrecognised-xml-attributes/test001.rdf" do
    execute_w3c_parser_test('unrecognised-xml-attributes/test001')
  end

  it "should pass unrecognised-xml-attributes/test002.rdf" do
    execute_w3c_parser_test('unrecognised-xml-attributes/test002')
  end

  it "should pass xml-canon/test001.rdf" do
    execute_w3c_parser_test('xml-canon/test001')
  end

  it "should pass rdfms-abouteach/error001.rdf" do
    execute_w3c_error_test('rdfms-abouteach/error001')
  end

  it "should pass rdfms-abouteach/error002.rdf" do
    execute_w3c_error_test('rdfms-abouteach/error002')
  end

  it "should pass rdfms-rdf-id/error001.rdf" do
    execute_w3c_error_test('rdfms-rdf-id/error001')
  end

  it "should pass rdfms-rdf-id/error002.rdf" do
    execute_w3c_error_test('rdfms-rdf-id/error002')
  end

  it "should pass rdfms-rdf-id/error003.rdf" do
    execute_w3c_error_test('rdfms-rdf-id/error003')
  end

  it "should pass rdfms-rdf-id/error004.rdf" do
    execute_w3c_error_test('rdfms-rdf-id/error004')
  end

  it "should pass rdfms-rdf-id/error005.rdf" do
    execute_w3c_error_test('rdfms-rdf-id/error005')
  end

  it "should pass rdfms-rdf-id/error006.rdf" do
    execute_w3c_error_test('rdfms-rdf-id/error006')
  end

  it "should pass rdfms-rdf-id/error007.rdf" do
    execute_w3c_error_test('rdfms-rdf-id/error007')
  end

  it "should pass rdf-containers-syntax-vs-schema/test001.rdf" do
    execute_w3c_parser_test('rdf-containers-syntax-vs-schema/test001')
  end

  it "should pass rdf-containers-syntax-vs-schema/test002.rdf" do
    execute_w3c_parser_test('rdf-containers-syntax-vs-schema/test002')
  end

  it "should pass rdf-containers-syntax-vs-schema/test003.rdf" do
    execute_w3c_parser_test('rdf-containers-syntax-vs-schema/test003')
  end

  it "should pass rdf-containers-syntax-vs-schema/test004.rdf" do
    execute_w3c_parser_test('rdf-containers-syntax-vs-schema/test004')
  end

  it "should pass rdf-containers-syntax-vs-schema/test006.rdf" do
    execute_w3c_parser_test('rdf-containers-syntax-vs-schema/test006')
  end

  it "should pass rdf-containers-syntax-vs-schema/test007.rdf" do
    execute_w3c_parser_test('rdf-containers-syntax-vs-schema/test007')
  end

  it "should pass rdf-containers-syntax-vs-schema/test008.rdf" do
    execute_w3c_parser_test('rdf-containers-syntax-vs-schema/test008')
  end
end
