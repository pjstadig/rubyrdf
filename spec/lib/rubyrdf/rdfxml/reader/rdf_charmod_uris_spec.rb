require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, 'rdf-charmod-uris' do
  include RDFXMLHelper

  it "should pass rdf-charmod-uris/test001.rdf" do
    execute_w3c_parser_test('rdf-charmod-uris/test001')
  end

  it "should pass rdf-charmod-uris/test002.rdf" do
    execute_w3c_parser_test('rdf-charmod-uris/test002')
  end
end
