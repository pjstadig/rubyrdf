module RDF
  class Statement
    attr_reader :subject, :predicate, :object
    
    def initialize(subject, predicate, object)
      @subject, @predicate, @object = subject, predicate, object
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
  end
end