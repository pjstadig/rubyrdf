require 'uri'

module URI #:nodoc:
  class Generic
    # Returns an instance of Addressable::URI representing this URI.
    def to_uri
      Addressable::URI.parse(to_s)
    end
  end
end

module Addressable #:nodoc:
  class URI
    class << self
      unless method_defined?(:parse_with_normalization)
        def parse_with_normalization(uri)
          parse_without_normalization(uri.to_str.mb_chars.normalize(:c))
        end
        alias_method_chain :parse, :normalization
      end
    end

    # Returns self
    def to_uri
      self
    end

    # Returns the NTriples serialization of this node.
    def to_ntriples
      "<#{RubyRDF::NTriples.escape_unicode(to_s)}>"
    end
  end
end
