require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "multiline-literal" do
  include RDFXMLHelper

  it "should pass multiline-literal/test001.rdf" do
    execute_parser_test('multiline-literal/test001')
  end
end
