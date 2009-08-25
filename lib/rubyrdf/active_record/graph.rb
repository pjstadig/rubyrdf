if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class Graph < ::ActiveRecord::Base
        has_and_belongs_to_many :statements, :class_name => "RubyRDF::ActiveRecord::Statement"
      end
    end
  end
end
