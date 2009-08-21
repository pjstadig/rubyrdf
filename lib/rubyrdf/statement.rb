module RubyRDF
  #--
  # TODO nodoc
  # TODO move InvalidStatement to here?
  # TODO conversion methods to/from hash?
  class Statement
    attr_reader :subject
    attr_reader :predicate
    attr_reader :object

    def initialize(subject, predicate, object)
      @subject = if subject.respond_to?(:to_uri)
                   subject.to_uri
                 elsif !subject.nil?
                   subject
                 else
                   raise InvalidStatementError, "#{subject} is not a valid subject"
                 end

      @predicate = if predicate.respond_to?(:to_uri)
                     predicate.to_uri
                   else
                     raise InvalidStatementError, "#{predicate} is not a valid predicate"
                   end

      @object = if object.respond_to?(:to_uri)
                  object.to_uri
                elsif object.respond_to?(:to_literal)
                  object.to_literal
                elsif !object.nil?
                  object
                else
                  raise InvalidStatementError, "#{object} is not a valid object"
                end
    end

    def ==(o)
      other = o.to_triple
      @subject == other[0] &&
        @predicate == other[1] &&
        @object == other[2]
    rescue NoMethodError, InvalidStatementError
      false
    end
    alias_method(:eql?, :==)

    def hash
      [-1070550737, @subject, @predicate, @object].hash
    end

    def inspect
      "#<#{self.class} #{node_ntriples(@subject)}, #{node_ntriples(@predicate)}, #{node_ntriples(@object)}>"
    end

    def to_statement
      self
    end

    def to_triple
      [@subject, @predicate, @object]
    end

    def to_ntriples
      MemoryGraph.new(self).export
    end

    private
    def node_ntriples(node)
      node.respond_to?(:to_ntriples) ? node.to_ntriples : node.to_s
    end
  end
end

class Array
  # Flattens the array, then does the following:
  # * if the array has a single element, then call to_statement on it
  # * if the array has three elements, then attempt to construct a RubyRDF::Statement
  # * otherwise, raise RubyRDF::InvalidStatementError
  def to_statement
    f = flatten
    if f.size == 1
      f[0].to_statement
    elsif f.size == 3
      RubyRDF::Statement.new(*f)
    else
      raise RubyRDF::InvalidStatementError
    end
  end

  # Flattens the array, then does the following:
  # * if the array has a single element, then call to_triple on it
  # * if the array has three elements, then returns the array of three elements
  # * otherwise, raise RubyRDF::InvalidStatementError
  def to_triple
    f = flatten
    if f.size == 1
      f[0].to_triple
    elsif f.size == 3
      s, p, o = f
      s = if s.respond_to?(:to_uri)
            s.to_uri
          else
            s
          end

      p = if p.respond_to?(:to_uri)
            p.to_uri
          else
            p
          end

      o = if o.respond_to?(:to_uri)
            o.to_uri
          elsif o.respond_to?(:to_literal)
            o.to_literal
          else
            o
          end

      [s, p, o]
    else
      raise RubyRDF::InvalidStatementError
    end
  end
end

class Object
  # Raises RubyRDF::InvalidStatementError
  def to_statement
    raise RubyRDF::InvalidStatementError
  end

  # Raises RubyRDF::InvalidStatementError
  def to_triple
    raise RubyRDF::InvalidStatementError
  end
end
