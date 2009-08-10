module RubyRDF
  module RDFXML
    class Reader
      class Document < Nokogiri::XML::SAX::Document
        RDF = Namespace::RDF
        XML = Namespace.new('http://www.w3.org/XML/1998/namespace/')

        def initialize(block)
          @block = block
          @root = nil
          @current = nil
          @text = nil
          @states = []
          @bnodes = {}
          @nodes = []
        end

        def start_document
          @root = RootEvent.new
        end

        def end_document
          if @states.last == :end_document
            @states.pop
          elsif @states.any?
            raise SyntaxError, "Unexpected end of document, expected #{@states.last}"
          end
        end

        def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
          if @root.document_element
            @current = ElementEvent.new(@current, name, uri, attrs)
          else
            @current = ElementEvent.new(@root, name, uri, attrs)
            @root.document_element = @current
          end

          if @states.empty?
            start_grammar
          elsif @states.last == :resource_literal_or_empty_property_elt
            node_element
            @nodes.push(@current)
          elsif @states.last == :end_element
            raise SyntaxError, "Expected end element not #{@current.uri}"
          elsif @states.last == :end_document
            raise SyntaxError, "Expected end of document not #{@current.uri}"
          else
            send(@states.last)
          end
        end

        def characters(string)
          @text = string
        end

        def end_element_namespace(name, prefix = nil, uri = nil)
          case @states.last
          when :end_element, :node_element_list, :property_elt_list
            @states.pop
          when :resource_literal_or_empty_property_elt
            resource_literal_or_empty_property_elt
          end
          @text = nil
          @current = @current.parent
        end

        # Grammar productions
        def core_syntax_terms?(uri)
          [RDF::RDF,
           RDF::ID,
           RDF::about,
           RDF::parseType,
           RDF::resource,
           RDF::nodeID,
           RDF::datatype].include?(uri)
        end

        def syntax_terms?(uri)
          core_syntax_terms?(uri) ||
            RDF::Description == uri ||
            RDF::li == uri
        end

        def old_terms?(uri)
          [RDF::aboutEach,
           RDF::aboutEachPrefix,
           RDF::bagID].include?(uri)
        end

        def node_element_uris?(uri)
          !core_syntax_terms?(uri) &&
            RDF::li != uri &&
            !old_terms?(uri)
        end

        def property_element_uris?(uri)
          !core_syntax_terms?(uri) &&
            RDF::Description != uri &&
            !old_terms?(uri)
        end

        def property_attribute_uris?(uri)
          !core_syntax_terms?(uri) &&
            RDF::Description != uri &&
            RDF::li != uri &&
            !old_terms?(uri)
        end

        def start_grammar
          if @current.parent == @root
            if doc?
              doc
            else
              node_element
            end
          else
            if rdf?
              rdf
            else
              node_element_list
            end
          end
        end

        def doc?
          rdf?
        end

        def doc
          @states.push(:end_document)
          rdf
        end

        def rdf?
          @current.uri == RDF::RDF
        end

        def rdf
          if @current.uri != RDF::RDF || @current.attributes.any?
            raise SyntaxError, "Expected rdf:RDF element with no attributes"
          end
          @states.push(:node_element_list)
        end

        def node_element_list
          if node_element?
            node_element
          else
            raise SyntaxError, "Expected nodeElementList not #{@current.uri}"
          end
        end

        def node_element?
          node_element_uris?(@current.uri)
        end

        def node_element
          raise SyntaxError, "Expected nodeElement" unless node_element?

          if id = @current.has_attribute?(RDF::ID)
            @current.subject = @current.resolve("##{id.string_value}")
          end

          if node_id = @current.has_attribute?(RDF::nodeID)
            raise SyntaxError, "Expected only one of rdf:ID, rdf:nodeID, rdf:about" if @current.subject
            @current.subject = (@bnodes[node_id.string_value] ||= Object.new)
          end

          if about = @current.has_attribute?(RDF::about)
            raise SyntaxError, "Expected only one of rdf:ID, rdf:nodeID, rdf:about" if @current.subject
            @current.subject = @current.resolve(about.string_value)
          end

          @current.subject = @bnodes[RubyRDF.generate_bnode_name] = Object.new unless @current.subject

          if @current.uri != RDF::Description
            @block.call(Statement.new(@current.subject, RDF::type, @current.uri))
          end

          property_attrs(@current.attributes).each do |a|
            if a.uri == RDF::type
              @block.call(Statement.new(@current.subject,
                                        RDF::type,
                                        @current.resolve(a.string_value)))
            else
              @block.call(Statement.new(@current.subject,
                                        a.uri,
                                        PlainLiteral.new(a.string_value, @current.language)))
            end
          end
          @states.push(:property_elt_list)
        end

        def property_attrs(attributes)
          attributes.select{|a| property_attribute_uris?(a.uri)}
        end

        def property_elt_list
          if property_elt?
            property_elt
          else
            raise SyntaxError, "Expected propertyEltList not #{@current.uri}"
          end
        end

        def property_elt?
          property_element_uris?(@current.uri)
        end

        def property_elt
          if parse_type_literal_property_elt?
            parse_type_literal_property_elt
          elsif parse_type_resource_property_elt?
            parse_type_resource_property_elt
          elsif parse_type_collection_property_elt?
            parse_type_collection_property_elt
          elsif parse_type_other_property_elt?
            parse_type_other_property_elt
          else
            @states.push(:resource_literal_or_empty_property_elt)
          end
        end

        def parse_type_literal_property_elt?
          a = @current.has_attribute?(RDF::parseType)
          a && a.string_value == "Literal"
        end

        def parse_type_resource_property_elt?
          a = @current.has_attribute?(RDF::parseType)
          a && a.string_value == "Resource"
        end

        def parse_type_collection_property_elt?
          a = @current.has_attribute?(RDF::parseType)
          a && a.string_value == "Collection"
        end

        def parse_type_other_property_elt?
          a = @current.has_attribute?(RDF::parseType)
          a && !["Literal", "Resource", "Collection"].include?(a.string_value)
        end

        def resource_literal_or_empty_property_elt
          if @text
            literal_property_elt
          elsif @nodes.any?
            resource_property_elt(@nodes.pop)
          else
            empty_property_elt
          end
          @states.pop
        end

        def literal_property_elt
          datatype = @current.has_attribute?(RDF::datatype)
          datatype = datatype && datatype.string_value
          begin
            datatype = datatype && Addressable::URI.parse(datatype)
          rescue
            raise SyntaxError, "Literal Datatype is not a valid URI #{datatype}"
          end

          if datatype
            @block.call(Statement.new(@current.parent.subject,
                                      @current.uri,
                                      TypedLiteral.new(@text, datatype)))
          else
            @block.call(Statement.new(@current.parent.subject,
                                      @current.uri,
                                      PlainLiteral.new(@text, @current.language)))
          end
        end

        def empty_property_elt
          if @current.attributes.empty? ||
              (@current.attributes.size == 1 &&
               (id = @current.has_attribute?(RDF::ID)))
            @block.call(s = Statement.new(@current.parent.subject,
                                      @current.uri,
                                      PlainLiteral.new("", @current.language)))
          else
            node = nil
            if resource = @current.has_attribute?(RDF::resource)
              node = @current.resolve(resource.string_value)
            end

            if node_id = @current.has_attribute?(RDF::nodeID)
              raise SyntaxError, "Expected only one of rdf:resource or rdf:nodeID" if node
              node = (bnodes[node_id.string_value] ||= Object.new)
            end
            node = bnodes[RubyRDF.generate_bnode_name] = Object.new unless node

            property_attributes(@current.attributes).each do |a|
              if a.uri == RDF::type
                block.call(Statement.new(node,
                                         RDF::type,
                                         Addressable::URI.parse(a.string_value)))
              else
                block.call(Statement.new(node,
                                         a.uri,
                                         PlainLiteral.new(a.string_value, @current.language)))
              end
            end
            block.call(s = Statement.new(@current.parent.subject,
                                         @current.uri,
                                         node))

            id = @current.has_attribute?(RDF::ID)
          end

          if id
            uri = @current.resolve("##{id.string_value}")
            @block.call(Statement.new(uri, RDF::subject, s.subject))
            @block.call(Statement.new(uri, RDF::predicate, s.predicate))
            @block.call(Statement.new(uri, RDF::object, s.object))
            @block.call(Statement.new(uri, RDF::type, RDF::Statement))
          end
        end
      end
    end
  end
end
