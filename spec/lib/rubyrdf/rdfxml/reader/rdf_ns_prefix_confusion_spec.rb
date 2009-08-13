require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader, "rdf-ns-prefix-confusion" do
  include RDFXMLHelper

  it "should pass rdf-ns-prefix-confusion/test0001.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0001')
  end

  it "should pass rdf-ns-prefix-confusion/test0003.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0003')
  end

  it "should pass rdf-ns-prefix-confusion/test0004.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0004')
  end

  it "should pass rdf-ns-prefix-confusion/test0005.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0005')
  end

  it "should pass rdf-ns-prefix-confusion/test0006.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0006')
  end

  it "should pass rdf-ns-prefix-confusion/test0009.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0009')
  end

  it "should pass rdf-ns-prefix-confusion/test0010.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0010')
  end

  it "should pass rdf-ns-prefix-confusion/test0011.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0011')
  end

  it "should pass rdf-ns-prefix-confusion/test0012.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0012')
  end

  it "should pass rdf-ns-prefix-confusion/test0013.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0013')
  end

  it "should pass rdf-ns-prefix-confusion/test0014.rdf" do
    execute_w3c_parser_test('rdf-ns-prefix-confusion/test0014')
  end
end
