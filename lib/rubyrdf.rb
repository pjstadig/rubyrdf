$kcode = 'u'
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rdf'
require 'rdf/error'
require 'rdf/blank_node'
require 'rdf/uri_node'
require 'rdf/plain_literal_node'
require 'rdf/typed_literal_node'
require 'rdf/statement'
require 'rdf/sparql_result'
require 'rdf/sesame/base'