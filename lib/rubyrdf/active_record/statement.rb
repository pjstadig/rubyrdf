if defined?(ActiveRecord)
  require 'rubyrdf/active_record'

  module RubyRDF
    class ActiveRecord
      class Statement < ::ActiveRecord::Base
        has_and_belongs_to_many :graphs, :class_name => "RubyRDF::ActiveRecord::Graph"

        belongs_to :subject, :polymorphic => true
        belongs_to :predicate, :polymorphic => true
        belongs_to :object, :polymorphic => true
      end
    end
  end
end
