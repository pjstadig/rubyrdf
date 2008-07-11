module RDF
  class Statement
    class InvalidSubjectError < Error
      def initialize(subject)
        super("Invalid Subject: #{subject}")
      end
    end
    
    class InvalidPredicateError < Error
      def initialize(predicate)
        super("Invalid Predicate: #{predicate}")
      end
    end
    
    class InvalidObjectError < Error
      def initialize(object)
        super("Invalid Object: #{object}")
      end
    end
    
    attr_reader :subject, :predicate, :object
    
    def initialize(subject, predicate, object)
      @subject, @predicate, @object = subject, predicate, object
      raise InvalidSubjectError.new(@subject) unless @subject.resource?
      raise InvalidPredicateError.new(@predicate) unless @predicate.uri_node?
      raise InvalidObjectError.new(@object) unless @object.node?
    end
    
    def hash
      [-614958737, @subject, @predicate, @object].hash
    end
    
    def ==(o)
      self.subject == o.subject &&
        self.predicate == o.predicate &&
        self.object == o.object
    rescue NoMethodError
      false
    end
    alias_method :eql?, :==
    
    def to_ntriples
      [@subject, @predicate, @object].map!{|n| n.to_ntriples}.join(' ') + " ."
    end
    alias_method :to_s, :to_ntriples
    
    def to_statement
      self
    end
  end
end

class Array
  def to_statement
    if self.size == 1
      self[0].to_statement
    else
      RDF::Statement.new(*self)
    end
  end
end