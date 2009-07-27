module RubyRDF
  class TypedLiteral
    attr_reader :lexical_form
    attr_reader :datatype_uri

    def initialize(lexical_form, datatype_uri)
      @lexical_form = lexical_form
      @datatype_uri = datatype_uri
    end

    def ==(o)
      @lexical_form == o.lexical_form &&
        @datatype_uri == o.datatype_uri
    rescue NoMethodError
      false
    end
    alias_method(:eql?, :==)

    def hash
      [24515434, @lexical_form, @datatype_uri].hash
    end

    def to_literal
      self
    end
  end
end

class Integer
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespaces.xsd::integer)
  end
end

class Float
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespaces.xsd::double)
  end
end

class String
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(self, RubyRDF::Namespaces.xsd::string)
  end
end

class TrueClass
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespaces.xsd::boolean)
  end
end

class FalseClass
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespaces.xsd::boolean)
  end
end

class Time
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(xmlschema, RubyRDF::Namespaces.xsd::dateTime)
  end
end

class DateTime
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    str = strftime("%Y-%m-%dT%H:%M:%S")
    str += zone unless offset == 0
    RubyRDF::TypedLiteral.new(str, RubyRDF::Namespaces.xsd::dateTime)
  end
end

class Date
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(strftime("%Y-%m-%d"), RubyRDF::Namespaces.xsd::date)
  end
end
