if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class URINode < ::ActiveRecord::Base
        def self.find_or_create_by_rdf(uri_node, bnodes)
          n = find_by_rdf(uri_node, bnodes)
          unless n
            n = create(:uri => uri_node.uri)
          end
          n
        end

        def self.find_by_rdf(uri_node, bnodes)
          find(:first,
               :conditions => {
                 :uri => uri_node.uri
               })
        end

        def to_rdf(bnodes)
          ::RubyRDF::URINode.new(uri)
        end
      end
    end
  end
end
