module RubyRDF
  class PlainLiteral
    attr_reader :lexical_form
    attr_reader :language_tag

    def initialize(lexical_form, language_tag = nil)
      @lexical_form = lexical_form.to_str.mb_chars.normalize(:c).to_str
      @language_tag = language_tag
    end

    def ==(o)
      @lexical_form == o.lexical_form &&
        @language_tag == o.language_tag
    rescue NoMethodError
      false
    end
    alias_method(:eql?, :==)

    def hash
      [-584159468, @lexical_form, @language_tag].hash
    end

    def to_literal
      self
    end
  end
end
