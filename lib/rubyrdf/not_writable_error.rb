module RubyRDF
  # Raised when a change is attempted for a read only graph.
  class NotWritableError < Error
  end
end
