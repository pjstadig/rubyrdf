require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "general" do
  include RDFXMLHelper

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
end
