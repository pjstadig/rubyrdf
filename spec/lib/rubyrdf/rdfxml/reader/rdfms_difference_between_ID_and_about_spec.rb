require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "rdfms-difference-between-ID-and-about" do
  include RDFXMLHelper

  it "should pass rdfms-difference-between-ID-and-about/test1.rdf" do
    execute_w3c_parser_test('rdfms-difference-between-ID-and-about/test1')
  end

  it "should pass rdfms-difference-between-ID-and-about/test2.rdf" do
    execute_w3c_parser_test('rdfms-difference-between-ID-and-about/test2')
  end

  it "should pass rdfms-difference-between-ID-and-about/test3.rdf" do
    execute_w3c_parser_test('rdfms-difference-between-ID-and-about/test3')
  end

  it "should pass rdfms-difference-between-ID-and-about/error1.rdf" do
    execute_w3c_error_test('rdfms-difference-between-ID-and-about/error1')
  end
end
