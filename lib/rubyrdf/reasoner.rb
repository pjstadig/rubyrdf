module RubyRDF
  #--
  # TODO backwards chaining
  # TODO rulesets
  class Reasoner
    class ConditionFailedError < StandardError
      attr_accessor :condition
      def initialize(condition)
        super("#{condition.inspect}")
        @condition = condition
      end
    end

    attr_reader :graph
    attr_reader :rules

    def initialize(graph, rules)
      @graph = graph
      @rules = rules.dup
    end

    def forward_chain
      @rules.each do |r|
        process_rule(r)
      end
    end

    private
    def process_rule(rule)
      bindings = rule.conditions.inject([]) do |r,c|
        r = process_condition(c, r)
        r
      end

      bindings.each do |b|
        s, p, o = rule.conclusion
        @graph.add(b[s], b[p], b[o])
      end
    rescue ConditionFailedError
      nil
    end

    def process_condition(cond, bindings)
      if bindings.empty?
        process_cond_binding(cond, Hash.new{|h,k| k})
      else
        bindings.inject([]) do |r,b|
          cond_bindings = process_cond_binding(cond, b)
          r += cond_bindings
          r
        end
      end
    end

    def process_cond_binding(cond, binding)
      result = @graph.match(binding[cond[0]], binding[cond[1]], binding[cond[2]])
      raise ConditionFailedError.new(cond) if result.empty?

      result.inject([]) do |r, m|
        b = binding.dup
        if variable?(cond[0])
          b[cond[0]] = m.subject
        end

        if variable?(cond[1])
          b[cond[1]] = m.predicate
        end

        if variable?(cond[2])
          b[cond[2]] = m.object
        end

        r << b unless b.empty?
        r
      end
    end

    def variable?(node)
      !@graph.known?(node)
    end
  end
end
