module ActiveRecordHelper
  def setup_db
    File.delete("test.db") if File.exists?("test.db")

    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "test.db")
    RubyRDF::ActiveRecord.initialize_db
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
