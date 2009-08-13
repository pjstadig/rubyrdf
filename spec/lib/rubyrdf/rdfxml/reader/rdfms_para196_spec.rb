require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "rdfms-para196" do
  include RDFXMLHelper

  it "should pass rdfms-para196/test001.rdf" do
    execute_w3c_parser_test('rdfms-para196/test001')
  end
end
