require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, 'rdfms-duplicate-member-props' do
  include RDFXMLHelper

  it "should pass rdfms-duplicate-member-props/test001.rdf" do
    execute_w3c_parser_test('rdfms-duplicate-member-props/test001')
  end
end
