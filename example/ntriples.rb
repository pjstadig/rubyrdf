$: << 'lib'
require 'rubyrdf'

File.open("spec/fixtures/w3c/Manifest.nt", "r") do |f|
  RubyRDF::NTriples::Reader.new(f).each{|s|}
end
