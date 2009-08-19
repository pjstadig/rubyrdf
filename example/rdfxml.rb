$: << 'lib'
require 'rubyrdf'

File.open("spec/fixtures/w3c/Manifest.rdf", "r") do |f|
  RubyRDF::RDFXML::Reader.new(f).each{|s|}
end
