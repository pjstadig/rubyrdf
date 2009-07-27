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
    # Returns self
    def to_uri
      self
    end
  end
end
