require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, 'rdfms-identity-anon-resources' do
  include RDFXMLHelper

  it "should pass rdfms-identity-anon-resources/test001.rdf" do
    execute_w3c_parser_test('rdfms-identity-anon-resources/test001')
  end

  it "should pass rdfms-identity-anon-resources/test002.rdf" do
    execute_w3c_parser_test('rdfms-identity-anon-resources/test002')
  end

  it "should pass rdfms-identity-anon-resources/test003.rdf" do
    execute_w3c_parser_test('rdfms-identity-anon-resources/test003')
  end

  it "should pass rdfms-identity-anon-resources/test004.rdf" do
    execute_w3c_parser_test('rdfms-identity-anon-resources/test004')
  end

  it "should pass rdfms-identity-anon-resources/test005.rdf" do
    execute_w3c_parser_test('rdfms-identity-anon-resources/test005')
  end
end
