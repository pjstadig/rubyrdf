require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, 'rdfms-empty-property-elements' do
  include RDFXMLHelper

  it "should pass rdfms-empty-property-elements/test001.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test001')
  end

  it "should pass rdfms-empty-property-elements/test002.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test002')
  end

  it "should pass rdfms-empty-property-elements/test003.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test003')
  end

  it "should pass rdfms-empty-property-elements/test004.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test004')
  end

  it "should pass rdfms-empty-property-elements/test005.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test005')
  end

  it "should pass rdfms-empty-property-elements/test006.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test006')
  end

  it "should pass rdfms-empty-property-elements/test007.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test007')
  end

  it "should pass rdfms-empty-property-elements/test008.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test008')
  end

  it "should pass rdfms-empty-property-elements/test009.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test009')
  end

  it "should pass rdfms-empty-property-elements/test010.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test010')
  end

  it "should pass rdfms-empty-property-elements/test011.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test011')
  end

  it "should pass rdfms-empty-property-elements/test012.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test012')
  end

  it "should pass rdfms-empty-property-elements/test013.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test013')
  end

  it "should pass rdfms-empty-property-elements/test014.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test014')
  end

  it "should pass rdfms-empty-property-elements/test015.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test015')
  end

  it "should pass rdfms-empty-property-elements/test016.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test016')
  end

  it "should pass rdfms-empty-property-elements/test017.rdf" do
    execute_w3c_parser_test('rdfms-empty-property-elements/test017')
  end

  it "should pass rdfms-empty-property-elements/error001.rdf" do
    execute_w3c_error_test('rdfms-empty-property-elements/error001')
  end

  it "should pass rdfms-empty-property-elements/error002.rdf" do
    execute_w3c_error_test('rdfms-empty-property-elements/error002')
  end

  it "should pass rdfms-empty-property-elements/error003.rdf" do
    execute_w3c_error_test('rdfms-empty-property-elements/error003')
  end
end
