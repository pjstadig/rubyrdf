require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "general" do
  include RDFXMLHelper

  it "should pass rdfms-seq-representation/test001.rdf" do
    execute_w3c_parser_test('rdfms-seq-representation/test001')
  end
end
