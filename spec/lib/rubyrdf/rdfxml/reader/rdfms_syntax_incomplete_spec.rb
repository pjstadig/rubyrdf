require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "rdfms-syntax-incomplete" do
  include RDFXMLHelper

  it "should pass rdfms-syntax-incomplete/test001.rdf" do
    execute_w3c_parser_test('rdfms-syntax-incomplete/test001')
  end

  it "should pass rdfms-syntax-incomplete/test002.rdf" do
    execute_w3c_parser_test('rdfms-syntax-incomplete/test002')
  end

  it "should pass rdfms-syntax-incomplete/test003.rdf" do
    execute_w3c_parser_test('rdfms-syntax-incomplete/test003')
  end

  it "should pass rdfms-syntax-incomplete/test004.rdf" do
    execute_w3c_parser_test('rdfms-syntax-incomplete/test004')
  end

  it "should pass rdfms-syntax-incomplete/error001.rdf" do
    execute_w3c_error_test('rdfms-syntax-incomplete/error001')
  end

  it "should pass rdfms-syntax-incomplete/error002.rdf" do
    execute_w3c_error_test('rdfms-syntax-incomplete/error002')
  end

  it "should pass rdfms-syntax-incomplete/error003.rdf" do
    execute_w3c_error_test('rdfms-syntax-incomplete/error003')
  end

  it "should pass rdfms-syntax-incomplete/error004.rdf" do
    execute_w3c_error_test('rdfms-syntax-incomplete/error004')
  end

  it "should pass rdfms-syntax-incomplete/error005.rdf" do
    execute_w3c_error_test('rdfms-syntax-incomplete/error005')
  end

  it "should pass rdfms-syntax-incomplete/error006.rdf" do
    execute_w3c_error_test('rdfms-syntax-incomplete/error006')
  end
end
