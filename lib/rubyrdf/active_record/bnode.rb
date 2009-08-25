if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class BNode < ::ActiveRecord::Base
        def self.find_or_create_by_rdf(bnode, bnodes)
          unless bnodes[:to_ar][bnode]
            b = create
            bnodes[:to_ar][bnode] = b.id
            bnodes[:from_ar][b.id] = bnode
          end
          find_by_id(bnodes[:to_ar][bnode])
        end

        def self.find_by_rdf(bnode, bnodes)
          if bnodes[:to_ar][bnode]
            find_by_id(bnodes[:to_ar][bnode])
          end
        end

        def to_rdf(bnodes)
          unless bnodes[:from_ar][self.id]
            o = Object.new
            bnodes[:from_ar][self.id] = o
            bnodes[:to_ar][o] = self.id
          end
          bnodes[:from_ar][self.id]
        end
      end
    end
  end
end
