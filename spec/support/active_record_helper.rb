module ActiveRecordHelper
  def setup_db
    File.delete("graph.db") if File.exists?("graph.db")

    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "graph.db")
    conn = ActiveRecord::Base.connection
    conn.create_table(:graphs){}

    conn.create_table(:statements) do |t|
      t.integer :subject_id, :predicate_id, :object_id
      t.string :subject_type, :predicate_type, :object_type
    end

    conn.create_table(:graphs_statements, :id => false) do |t|
      t.integer :graph_id, :statement_id
    end

    conn.create_table(:uri_nodes) do |t|
      t.string :uri
    end

    conn.create_table(:plain_literals) do |t|
      t.string :lexical_form, :language_tag
    end

    conn.create_table(:typed_literals) do |t|
      t.string :lexical_form, :datatype_uri
    end

    conn.create_table(:b_nodes){}
  end

  def reset_db
    RubyRDF::ActiveRecord::Graph.destroy_all
    RubyRDF::ActiveRecord::Statement.destroy_all
    RubyRDF::ActiveRecord::URINode.destroy_all
    RubyRDF::ActiveRecord::PlainLiteral.destroy_all
    RubyRDF::ActiveRecord::TypedLiteral.destroy_all
    RubyRDF::ActiveRecord::BNode.destroy_all
  end
end
