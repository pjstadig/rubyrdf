require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "rdfms-xml-base" do
  include RDFXMLHelper

  it "should pass xmlbase/test001.rdf" do
    execute_w3c_parser_test('xmlbase/test001')
  end

  it "should pass xmlbase/test002.rdf" do
    execute_w3c_parser_test('xmlbase/test002')
  end

  it "should pass xmlbase/test003.rdf" do
    execute_w3c_parser_test('xmlbase/test003')
  end

  it "should pass xmlbase/test004.rdf" do
    execute_w3c_parser_test('xmlbase/test004')
  end

  it "should pass xmlbase/test006.rdf" do
    execute_w3c_parser_test('xmlbase/test006')
  end

  it "should pass xmlbase/test007.rdf" do
    execute_w3c_parser_test('xmlbase/test007')
  end

  it "should pass xmlbase/test008.rdf" do
    execute_w3c_parser_test('xmlbase/test008')
  end

  it "should pass xmlbase/test009.rdf" do
    execute_w3c_parser_test('xmlbase/test009')
  end

  it "should pass xmlbase/test010.rdf" do
    execute_w3c_parser_test('xmlbase/test010')
  end

  it "should pass xmlbase/test011.rdf" do
    execute_w3c_parser_test('xmlbase/test011')
  end

  it "should pass xmlbase/test013.rdf" do
    execute_w3c_parser_test('xmlbase/test013')
  end

  it "should pass xmlbase/test014.rdf" do
    execute_w3c_parser_test('xmlbase/test014')
  end
end
