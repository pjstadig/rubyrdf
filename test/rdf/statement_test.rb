require File.dirname(__FILE__) + '/../test_helper.rb'

class RDF::StatementTest < Test::Unit::TestCase
  def setup
    RDF.unregister_all!
    RDF.register(:ex => 'http://example.org/')
    @ex = RDF[:ex]
  end
  
  def test_should_initialize_subject_predicate_and_object
    stmt = RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj)
    assert_equal @ex::sub, stmt.subject
    assert_equal @ex::pred, stmt.predicate
    assert_equal @ex::obj, stmt.object
  end
  
  def test_should_validate_subject
    assert_raise(RDF::Statement::InvalidSubjectError) {
      RDF::Statement.new(RDF::PlainLiteralNode.new('test'), @ex::pred, @ex::obj)
    }
  end
  
  def test_should_validate_predicate
    assert_raise(RDF::Statement::InvalidPredicateError) {
      RDF::Statement.new(@ex::sub, RDF::PlainLiteralNode.new('test'), @ex::obj)
    }
  end
  
  def test_should_validate_object
    assert_raise(RDF::Statement::InvalidObjectError) {
      RDF::Statement.new(@ex::sub, @ex::pred, 'test')
    }
  end
  
  def test_should_be_eq
    assert RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj) ==
           RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj)
  end
  
  def test_should_not_be_eq
    assert RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj) != nil
    assert RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj) !=
           RDF::Statement.new(@ex::sub2, @ex::pred, @ex::obj)
    assert RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj) !=
           RDF::Statement.new(@ex::sub, @ex::pred2, @ex::obj)
    assert RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj) !=
           RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj2)
  end
  
  def test_should_be_eql
    assert RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).eql?(
      RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj))
  end
  
  def test_should_not_be_eql
    assert !RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).eql?(nil)
    assert !RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).eql?(
      RDF::Statement.new(@ex::sub2, @ex::pred, @ex::obj))
    assert !RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).eql?(
      RDF::Statement.new(@ex::sub, @ex::pred2, @ex::obj))
    assert !RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).eql?(
      RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj2))
  end
  
  def test_should_have_same_hash
    assert_equal RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).hash,
                 RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).hash
  end
  
  def test_should_export_to_ntriples_format
    assert_equal '<http://example.org/sub> <http://example.org/pred> <http://example.org/obj> .',
                 RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).to_ntriples
    assert_equal '<http://example.org/sub> <http://example.org/pred> <http://example.org/obj> .',
                 RDF::Statement.new(@ex::sub, @ex::pred, @ex::obj).to_s
  end
end