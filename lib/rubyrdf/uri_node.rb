module RubyRDF
  class URINode
    attr_reader :uri

    def initialize(uri)
      uri = uri.to_str
      uri = if uri.respond_to?(:utf8nfc)
              uri.utf8nfc.to_str
            else
              uri.mb_chars.normalize(:c).to_str
            end

      begin
        URI.parse(uri)
      rescue URI::InvalidURIError
        Addressable::URI.parse(uri)
      end
      @uri = uri
    end

    def ==(o)
      @uri == o.uri
    rescue NoMethodError
      false
    end
    alias_method :eql?, :==

    def hash
      [-14127546, @uri].hash
    end

    def to_ntriples
      "<#{NTriples.escape_unicode(@uri)}>"
    end
    alias_method :inspect, :to_ntriples

    def to_uri
      self
    end

    alias_method :to_s, :uri
  end
end

class URI::Generic
  def to_uri
    @uri_node ||= RubyRDF::URINode.new(to_s)
  end
end

class Addressable::URI
  def to_uri
    @uri_node ||= RubyRDF::URINode.new(to_s)
  end
end
