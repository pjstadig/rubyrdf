$: << 'lib'
require 'rubyrdf'

File.open("spec/fixtures/Manifest.nt", "r") do |f|
  RubyRDF::NTriples::Reader.new(f).each{|s|}
end
