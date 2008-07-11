Gem::Specification.new do |s|
  s.name = %q{rubyrdf}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Stadig"]
  s.date = %q{2008-07-11}
  s.description = %q{description of gem}
  s.email = ["paul@stadig.name"]
  s.extra_rdoc_files = ["History.txt", "License.txt", "README.txt", "TODO.txt"]
  s.files = ["History.txt", "License.txt", "README.txt", "TODO.txt", "lib/rdf.rb", "lib/rdf/blank_node.rb", "lib/rdf/error.rb", "lib/rdf/ntriples_helper.rb", "lib/rdf/plain_literal_node.rb", "lib/rdf/sesame/base.rb", "lib/rdf/sparql_result.rb", "lib/rdf/statement.rb", "lib/rdf/typed_literal_node.rb", "lib/rdf/uri_node.rb", "lib/rdf/version.rb", "lib/rubyrdf.rb", "test/rdf/blank_node_test.rb", "test/rdf/plain_literal_node_test.rb", "test/rdf/sesame/base_test.rb", "test/rdf/sparql_result_test.rb", "test/rdf/statement_test.rb", "test/rdf/typed_literal_node_test.rb", "test/rdf/uri_node_test.rb", "test/rdf_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rubyrdf.rubyforge.org}
  s.post_install_message = %q{
For more information on rubyrdf, see http://rubyrdf.rubyforge.org

NOTE: Change this information in PostInstall.txt 
You can also delete it if you don't want it.


}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rubyrdf}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{description of gem}
  s.test_files = ["test/rdf/blank_node_test.rb", "test/rdf/statement_test.rb", "test/rdf/plain_literal_node_test.rb", "test/rdf/sparql_result_test.rb", "test/rdf/typed_literal_node_test.rb", "test/rdf/uri_node_test.rb", "test/rdf/sesame/base_test.rb", "test/rdf_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
    else
    end
  else
  end
end
