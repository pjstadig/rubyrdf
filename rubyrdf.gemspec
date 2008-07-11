Gem::Specification.new do |s|
  s.name = "rubyrdf"
  s.version = "0.0.1"
  s.authors = ["Paul Stadig"]
  s.date = "2008-07-11"
  s.description = "A Resource Description Framework (RDF) library for Ruby."
  s.email = "paul@stadig.name"
  s.extra_rdoc_files = ["History.txt", "License.txt", "README.txt", "TODO.txt"]
  s.files = ["History.txt", "License.txt", "README.txt", "TODO.txt", "lib/rdf.rb", "lib/rdf/blank_node.rb", "lib/rdf/error.rb", "lib/rdf/ntriples_helper.rb", "lib/rdf/plain_literal_node.rb", "lib/rdf/sesame/base.rb", "lib/rdf/sparql_result.rb", "lib/rdf/statement.rb", "lib/rdf/typed_literal_node.rb", "lib/rdf/uri_node.rb", "lib/rdf/version.rb", "lib/rubyrdf.rb", "test/rdf/blank_node_test.rb", "test/rdf/plain_literal_node_test.rb", "test/rdf/sesame/base_test.rb", "test/rdf/sparql_result_test.rb", "test/rdf/statement_test.rb", "test/rdf/typed_literal_node_test.rb", "test/rdf/uri_node_test.rb", "test/rdf_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = "http://rubyrdf.rubyforge.org"
  s.rdoc_options = ["--main", "README.txt"]
  s.summary = "description of gem"
  s.test_files = ["test/rdf/blank_node_test.rb", "test/rdf/statement_test.rb", "test/rdf/plain_literal_node_test.rb", "test/rdf/sparql_result_test.rb", "test/rdf/typed_literal_node_test.rb", "test/rdf/uri_node_test.rb", "test/rdf/sesame/base_test.rb", "test/rdf_test.rb"]
end
