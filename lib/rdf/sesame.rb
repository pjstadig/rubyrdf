require 'uri'
require 'net/http'

module RDF
  class Sesame
    def self.new(*a, &b)
      Version2.new(*a, &b)
    end
  end
end