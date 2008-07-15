$KCODE = 'utf8'
$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
  $:.include?(File.expand_path(File.dirname(__FILE__)))

gem 'activesupport','>=1.4.0'
require 'activesupport'

require 'rdf'
require 'rdf/error'
require 'rdf/node'
require 'rdf/blank_node'
require 'rdf/uri_node'
require 'rdf/plain_literal_node'
require 'rdf/typed_literal_node'
require 'rdf/statement'
require 'rdf/sparql_result'
require 'rdf/sesame'