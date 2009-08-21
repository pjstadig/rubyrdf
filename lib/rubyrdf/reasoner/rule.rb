module RubyRDF
  class Reasoner
    class Rule
      attr_reader :conditions
      attr_accessor :conclusion
      attr_reader :name

      def initialize(*a)
        conditions, conclusion, name = a

        @conditions = [].concat(conditions.to_a)
        @conclusion = conclusion
        @name = name
        yield self
      end

      def condition(*a)
        statement = statement_a(a)
        @conditions << statement
      end

      def conclusion(*a)
        return @conclusion if a.empty?
        @conclusion = statement_a(a)
      end

      def name(*a)
        return @name if a.empty?
        @name = a[0]
      end

      private
      def statement_a(a)
        if a.size == 3
          a
        else
          a[0].to_a
        end
      end
    end
  end
end
