module RubyRDF
  #--
  # TODO to_ruby? or should that happen automatically from graph?
  class TypedLiteral
    attr_reader :lexical_form
    attr_reader :datatype_uri

    def initialize(lexical_form, datatype_uri)
      @lexical_form = lexical_form.to_str
      @lexical_form = if @lexical_form.respond_to?(:utf8nfc)
                        @lexical_form.utf8nfc.to_str
                      else
                        @lexical_form.mb_chars.normalize(:c).to_str
                      end

      @datatype_uri = if datatype_uri.respond_to?(:to_uri)
                        datatype_uri.to_uri
                      else
                        RubyRDF::URINode.new(datatype_uri.to_str)
                      end
    end

    def ==(o) #:nodoc:
      @lexical_form == o.lexical_form &&
        @datatype_uri == o.datatype_uri
    rescue NoMethodError
      false
    end
    alias_method(:eql?, :==)

    def hash #:nodoc:
      [24515434, @lexical_form, @datatype_uri].hash
    end

    # Returns self
    def to_literal
      self
    end

    # Returns the NTriples serialization of this node.
    def to_ntriples
      %Q("#{NTriples.escape(@lexical_form)}"^^#{@datatype_uri.to_ntriples})
    end
    alias_method :to_s, :to_ntriples
    alias_method :inspect, :to_ntriples
  end
end

class Integer
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespace::XSD::integer)
  end
end

class Float
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespace::XSD::double)
  end
end

class String
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(self, RubyRDF::Namespace::XSD::string)
  end
end

class TrueClass
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespace::XSD::boolean)
  end
end

class FalseClass
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(to_s, RubyRDF::Namespace::XSD::boolean)
  end
end

class Time
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(xmlschema, RubyRDF::Namespace::XSD::dateTime)
  end
end

class DateTime
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    str = strftime("%Y-%m-%dT%H:%M:%S")
    str += zone unless offset == 0
    RubyRDF::TypedLiteral.new(str, RubyRDF::Namespace::XSD::dateTime)
  end
end

class Date
  # Returns a RubyRDF::TypedLiteral representing this object.
  def to_literal
    RubyRDF::TypedLiteral.new(strftime("%Y-%m-%d"), RubyRDF::Namespace::XSD::date)
  end
end
