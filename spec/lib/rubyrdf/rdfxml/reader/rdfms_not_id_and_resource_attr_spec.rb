require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, 'rdfms-not-id-and-resource-attr' do
  include RDFXMLHelper

  it "should pass rdfms-not-id-and-resource-attr/test001.rdf" do
    execute_w3c_parser_test('rdfms-not-id-and-resource-attr/test001')
  end

  it "should pass rdfms-not-id-and-resource-attr/test002.rdf" do
    execute_w3c_parser_test('rdfms-not-id-and-resource-attr/test002')
  end

  it "should pass rdfms-not-id-and-resource-attr/test004.rdf" do
    execute_w3c_parser_test('rdfms-not-id-and-resource-attr/test004')
  end

  it "should pass rdfms-not-id-and-resource-attr/test005.rdf" do
    execute_w3c_parser_test('rdfms-not-id-and-resource-attr/test005')
  end
end
