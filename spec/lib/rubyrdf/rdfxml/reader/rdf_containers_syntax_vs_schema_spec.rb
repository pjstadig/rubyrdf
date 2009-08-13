require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, 'rdf-containers-syntax-vs-schema' do
  include RDFXMLHelper

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

  it "should pass rdf-containers-syntax-vs-schema/error001.rdf" do
    execute_w3c_error_test('rdf-containers-syntax-vs-schema/error001')
  end

  it "should pass rdf-containers-syntax-vs-schema/error002.rdf" do
    execute_w3c_error_test('rdf-containers-syntax-vs-schema/error002')
  end
end
