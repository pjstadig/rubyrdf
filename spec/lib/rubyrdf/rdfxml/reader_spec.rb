require File.expand_path(File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper]))

describe RubyRDF::RDFXML::Reader do
  def rdf
    RubyRDF::Namespace::RDF
  end

  def xsd
    RubyRDF::Namespace::XSD
  end

  def compare(xml, *expected)
    actual = RubyRDF::RDFXML::Reader.new(StringIO.new(xml)).to_set
    expected.map{|s| s.to_statement}.each do |s|
      if actual.empty?
        s.should == nil
      end

      actual.delete_if{|o|
        (s.subject == o.subject || s.subject.instance_of?(Object) && o.subject.instance_of?(Object)) &&
        s.predicate == o.predicate &&
        (s.object == o.object || s.object.instance_of?(Object) && o.object.instance_of?(Object))
      }
    end
    actual.should == Set.new
  end

  it "should pass amp-in-url/test001.rdf" do
    xml = <<END
<?xml version="1.0"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
  <rdf:Description rdf:about="http://example/q?abc=1&#38;def=2">
    <rdf:value>xxx</rdf:value>
  </rdf:Description>
</rdf:RDF>
END
    compare(xml, [Addressable::URI.parse("http://example/q?abc=1&def=2"),
                  rdf::value,
                  RubyRDF::PlainLiteral.new("xxx")])
  end

  it "should pass datatypes/test001.rdf" do
    xml = <<END
<?xml version="1.0"?>

<!--
  Copyright World Wide Web Consortium, (Massachusetts Institute of
  Technology, Institut National de Recherche en Informatique et en
  Automatique, Keio University).

  All Rights Reserved.

  Please see the full Copyright clause at
  <http://www.w3.org/Consortium/Legal/copyright-software.html>

  Description: A simple datatype production; a language+
        datatype production. Simply duplicate the constructs under
        http://www.w3.org/2000/10/rdf-tests/rdfcore/ntriples/test.nt

  $Id: test001.rdf,v 1.2 2002/11/20 14:51:34 jgrant Exp $

-->

<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:eg="http://example.org/">

 <rdf:Description rdf:about="http://example.org/foo">
   <eg:bar rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">10</eg:bar>
   <eg:baz rdf:datatype="http://www.w3.org/2001/XMLSchema#integer" xml:lang="fr">10</eg:baz>
 </rdf:Description>

</rdf:RDF>
END
    ex = RubyRDF::Namespace.new("http://example.org/")
    compare(xml, [ex::foo, ex::bar, 10.to_literal], [ex::foo, ex::baz, 10.to_literal])
  end

  it "should pass datatypes/test002.rdf" do
    xml = <<END
<?xml version="1.0"?>

<!--
  Copyright World Wide Web Consortium, (Massachusetts Institute of
  Technology, Institut National de Recherche en Informatique et en
  Automatique, Keio University).

  All Rights Reserved.

  Please see the full Copyright clause at
  <http://www.w3.org/Consortium/Legal/copyright-software.html>

  Description: A parser is not required to know about well-formed
        datatyped literals.

  $Id: test002.rdf,v 1.1 2002/11/19 14:04:16 jgrant Exp $

-->

<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:eg="http://example.org/">

 <rdf:Description rdf:about="http://example.org/foo">
   <eg:bar rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">flargh</eg:bar>
 </rdf:Description>

</rdf:RDF>
END
    ex = RubyRDF::Namespace.new("http://example.org/")
    compare(xml, [ex::foo, ex::bar, RubyRDF::TypedLiteral.new("flargh", xsd::integer)])
  end

  it "should pass rdf-element-not-mandatory/test001.rdf" do
    xml = <<END
<?xml version="1.0" encoding="utf-8"?>
<!--
  Please see the full Copyright clause at
  <http://www.w3.org/Consortium/Legal/copyright-software.html>

  Description: the rdf:RDF element is no longer mandatory.

  $Id: test001.rdf,v 1.1 2003/10/08 13:00:58 jgrant Exp $

-->

<Book xmlns="http://example.org/terms#">
  <title>Dogs in Hats</title>
</Book>
END
    ex = RubyRDF::Namespace.new("http://example.org/terms#")
    compare(xml,
            [bn = Object.new, rdf::type, ex::Book],
            [bn, ex::title, RubyRDF::PlainLiteral.new("Dogs in Hats")])
  end

  it "should pass rdfms-reification-required/test001.rdf" do
    xml = <<END
<!--
  Copyright World Wide Web Consortium, (Massachusetts Institute of
  Technology, Institut National de Recherche en Informatique et en
  Automatique, Keio University).

  All Rights Reserved.

  Please see the full Copyright clause at
  <http://www.w3.org/Consortium/Legal/copyright-software.html>

$Id: test001.rdf,v 1.3 2002/04/05 11:32:03 bmcbride Exp $
-->
<!--

 Assumed base URI:

http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfms-reification-required/test001.rdf

 Description:

 A parser is not required to generate a bag of reified statements for all
 description elements.
-->

<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:eg="http://example.org#">
  <rdf:Description rdf:about="http://example.org/" eg:prop="10"/>
</rdf:RDF>

END
    ex = RubyRDF::Namespace.new("http://example.org#")
    compare(xml, [Addressable::URI.parse("http://example.org/"),
                 ex::prop,
                 RubyRDF::PlainLiteral.new("10")])
  end

  it "should pass rdfms-uri-substructure/test001.rdf" do
    xml = <<END
<!--
  Copyright World Wide Web Consortium, (Massachusetts Institute of
  Technology, Institut National de Recherche en Informatique et en
  Automatique, Keio University).

  All Rights Reserved.

  Please see the full Copyright clause at
  <http://www.w3.org/Consortium/Legal/copyright-software.html>

$Id: test001.rdf,v 1.1 2002/03/29 15:09:58 bmcbride Exp $
-->
<!--

 Description:

 Demonstrates the Recommended partitioning of a URI into a namespace
 part and a localname part

-->
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:eg="http://example.org/">

<rdf:Description>
  <eg:property>10</eg:property>
</rdf:Description>

</rdf:RDF>

END
    ex = RubyRDF::Namespace.new("http://example.org/")
    compare(xml, [Object.new, ex::property, RubyRDF::PlainLiteral.new("10")])
  end

  it "should pass rdfms-xmllang/test001.rdf" do
    xml = <<END
<?xml version="1.0"?>

<!--
  Copyright World Wide Web Consortium, (Massachusetts Institute of
  Technology, Institut National de Recherche en Informatique et en
  Automatique, Keio University).

  All Rights Reserved.

  Please see the full Copyright clause at
  <http://www.w3.org/Consortium/Legal/copyright-software.html>

  Issue: http://www.w3.org/2000/03/rdf-tracking/#rdfms-xmllang
  Test:  1
  Author: Dave Beckett

    In-scope xml:lang applies to rdf:parseType="Literal"
    element content values


  $Id: test001.rdf,v 1.2 2002/04/08 14:42:17 dajobe Exp $
-->

<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:eg="http://example.org/">

  <rdf:Description rdf:about="http://example.org/node">
     <eg:property rdf:parseType="Literal">chat</eg:property>
  </rdf:Description>
</rdf:RDF>
END
    ex = RubyRDF::Namespace.new("http://example.org/")
    compare(xml, [ex::node, ex::property, RubyRDF::TypedLiteral.new("chat", rdf::XMLLiteral)])
  end

  it "should use the W3C test cases"
end
