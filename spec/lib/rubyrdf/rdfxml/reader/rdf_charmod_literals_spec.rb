require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "rdf-charmod-literals" do
  include RDFXMLHelper

  it "should pass rdf-charmod-literals/test001.rdf" do
    execute_w3c_parser_test('rdf-charmod-literals/test001')
  end
end
