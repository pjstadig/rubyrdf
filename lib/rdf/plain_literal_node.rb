module RDF
  class PlainLiteralNode < Node
    attr_reader :lexical_form, :language_tag

    def initialize(lexical_form, language_tag = nil)
      super()
      @lexical_form = lexical_form.mb_chars.normalize(:c).to_s
      @language_tag = language_tag
    end

    def hash
      [-1025818701, @lexical_form, @language_tag].hash
    end

    def ==(o)
      self.lexical_form == o.lexical_form &&
        self.language_tag == o.language_tag
    rescue NoMethodError
      false
    end
    alias_method :eql?, :==

    def to_ntriples
      %Q("#{escape_ntriples(@lexical_form)}"#{@language_tag ? "@#{@language_tag}" : ''})
    end
    alias_method :to_s, :to_ntriples

    def plain_literal_node?
      true
    end
  end
end
