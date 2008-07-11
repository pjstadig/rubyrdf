$kcode = 'u'
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module RDF
end

require 'rdf/blank_node'
require 'rdf/uri_node'
require 'rdf/plain_literal_node'