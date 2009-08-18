module RubyRDF
  module RDFXML
    class Reader
      class Document < Nokogiri::XML::SAX::Document
        RDF = Namespace::RDF
        XML = Namespace.new('http://www.w3.org/XML/1998/namespace/')

        def initialize(block, base_uri)
          @block = block
          @root = nil
          @current = nil
          @states = []
          @bnodes = {}
          @ids = {}
          @nodes = []
          @literal_root = nil
          @literal_current = nil
          @resource = nil
          @base_uri = base_uri
          @events = []
          @parent = nil
          @parse_mode = :normal
          @literal_start = nil
          @eos = false
          @last_node = nil
          @last_event = nil
        end

        # SAX callbacks
        def start_document
          @parent = @root = RootEvent.new(@base_uri)
          @events << @root
          parse
        end

        def end_document
          @events << EndDocumentEvent.new
          @eos = true
          while @events.any?
            dispatch
          end
        end

        def start_element_namespace(name, attrs = [], prefix = nil, uri = nil, ns = [])
          @parent = ElementEvent.new(@parent, name, uri, attrs)
          @events << @parent
          parse
        end

        def characters(string)
          @events << TextEvent.new(@parent, string)
          parse
        end

        def end_element_namespace(name, prefix = nil, uri = nil)
          @parent = @parent.parent unless @parent == @root
          @events << EndElementEvent.new(name, uri)
          parse
        end

        def peek(index = 1)
          @events[index - 1]
        end

        def peek_type?(t, count = 1)
          i = 0
          total = 0
          while i < @events.size && total < count
            total += 1 if !@events[i].is_a?(t)
            i += 1
          end
          true if total == count
        end

        def peek_type(t)
          i = 0
          while i < @events.size && !@events[i].is_a?(t)
            i += 1
          end
          @events[i]
        end

        def peek_element()
          peek_type(ElementEvent)
        end

        # Handlers
        def parse
          while peek_type?(ElementEvent, 2) && (@events.size >= 1000 || @eos)
            dispatch
          end
        end

        def dispatch
          @current = @events.shift
          if @parse_mode == :normal
            handle_event
          elsif @parse_mode == :literal
            handle_literal_event
          else
            raise "Unknown parse mode"
          end
        end

        def handle_literal_event
          case @current
          when ElementEvent
            @states.push(:literal)
            new_node = Nokogiri::XML::Element.new(@current.local_name, @literal_doc.document)
            # TODO add the attributes
            @literal_doc << new_node
            @literal_doc = new_node
          when EndElementEvent
            if @states.last != :literal
              end_parse_type_literal_property_elt
            else
              @states.pop
              @literal_doc = @literal_doc.parent
            end
          when TextEvent
            new_node = Nokogiri::XML::Text.new(@current.string, @literal_doc.document)
            @literal_doc << new_node
          else
            raise "Unknown event type"
          end
        end

        def handle_event
          p @current if $debug
          case @current
          when RootEvent
          when ElementEvent, TextEvent, EndElementEvent
            handle_start_element
          when EndDocumentEvent
            while [:wses].include?(@states.last)
              @states.pop
            end

            if @states.last == :end_document
              @states.pop
            elsif @states.any?
              syntax_error("Unexpected end of document, expected #{@states.last}")
            end
          else
            raise "Unknown event type"
          end
          p @states if $debug
        end

        def handle_start_element
          if @states.empty?
            start_grammar
          elsif @states.last == :end_document
            syntax_error("Expected end of document not #{@current.inspect}")
          else
            send(@states.last)
          end
        end

        def end_element_event?(event = @current)
          event.is_a?(EndElementEvent)
        end

        def end_element_event
          unless @states.last == :end_element_event
            syntax_error("Unexpected end of element, expected #{@states.last}")
          end

          @states.pop
        end

        # Grammar productions
        def syntax_error(message)
          raise SyntaxError, message
        end

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
          syntax_error("rdf:aboutEach has been withdrawn from the language") if uri == RDF::aboutEach
          syntax_error("rdf:aboutEachPrefix has been withdrawn from the language") if uri == RDF::aboutEachPrefix
          syntax_error("rdf:bagID has been withdrawn from the language") if uri == RDF::bagID
          false
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
          syntax_error("rdf:li is not allowed as an element") if RDF::li == uri
          !core_syntax_terms?(uri) &&
            RDF::Description != uri &&
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

        def doc?(event = @current)
          event.is_a?(ElementEvent) &&
            rdf?(event)
        end

        def doc
          @states.push(:end_document)
          rdf
        end

        def rdf?(event = @current)
          event.is_a?(ElementEvent) &&
            event.uri == RDF::RDF
        end

        def rdf
          if @current.uri != RDF::RDF || @current.attributes.any?
            syntax_error("Expected rdf:RDF element with no attributes")
          end

          if node_element_list?(peek)
            @states.push(:node_element_list)
          else
            @states.push(:end_element_event)
          end
        end

        def ws?(event = @current)
          event.is_a?(TextEvent) &&
            event.string.blank?
        end

        def ws
          syntax_error("Expected ws") unless ws?
        end

        def wses
          @states.pop unless ws?(peek)
        end

        def node_element_list?(event = @current)
          ws?(event) || node_element?(event)
        end

        def node_element_list
          if ws?
            ws
          elsif node_element?
            node_element
          elsif end_element_event?
            @states.pop
          else
            syntax_error("Expected nodeElementList, not #{@current.inspect}")
          end
        end

        def node_element?(event = @current)
          event.is_a?(ElementEvent) &&
            node_element_uris?(event.uri)
        end

        def node_element
          raise SyntaxError, "Expected nodeElement not #{@current.inspect}" unless node_element?

          if id = @current.rdf_id
            uri = @current.resolve("##{id.string_value}")
            syntax_error("rdf:ID #{uri} is already in use") if @ids.has_key?(uri)
            @ids[uri] = uri
            @current.subject = uri
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

          if property_elt_list?(peek)
            @states.push(:property_elt_list)
          else
            @states.push(:end_element_event)
          end

          @current
        end

        def property_attrs(attributes)
          attributes.select{|a| property_attribute_uris?(a.uri)}
        end

        def property_elt_list?(event = @current, next_event = peek)
          ws?(event) || property_elt?(event, next_event)
        end

        def property_elt_list
          if ws?
            ws
          elsif property_elt?
            property_elt
          elsif end_element_event?
            @states.pop
          else
            syntax_error("Expected propertyEltList, not #{@current.inspect}")
          end
        end

        def property_elt?(event = @current, next_event = peek)
          resource_property_elt?(event, next_event) ||
            literal_property_elt?(event, next_event) ||
            parse_type_literal_property_elt?(event) ||
            parse_type_resource_property_elt?(event) ||
            parse_type_collection_property_elt?(event) ||
            parse_type_other_property_elt?(event) ||
            empty_property_elt?(event, next_event)
        end

        def property_elt
          syntax_error("Expected propertyElt, not #{@current.inspect}") unless property_elt?

          if @current.uri == RDF::li
            @current.uri = RubyRDF::URINode.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#_#{@current.parent.li_counter}")
            @current.parent.li_counter += 1
          end

          if parse_type_literal_property_elt?
            parse_type_literal_property_elt
          elsif parse_type_resource_property_elt?
            parse_type_resource_property_elt
          elsif parse_type_collection_property_elt?
            parse_type_collection_property_elt
          elsif parse_type_other_property_elt?
            parse_type_other_property_elt
          elsif resource_property_elt?
            if @current.attributes.any?{|a| a.uri != RDF::ID}
              syntax_error("Only rdf:id is allowed as a property of resourcePropertyElt")
            end
            @states.push(:end_element_event)
            @states.push(:resource_property_elt)
          elsif empty_property_elt?
            empty_property_elt
          elsif literal_property_elt?
            literal_property_elt
          else
            syntax_error("Expected propertyElt, not #{@current.inspect}")
          end
        end

        def resource_property_elt?(event = @current, next_event = peek)
          event.is_a?(ElementEvent) &&
            property_element_uris?(event.uri) &&
            (ws?(next_event) || node_element?(next_event))
        end

        def resource_property_elt
          if ws?
            ws
          elsif node_element?
            @states.pop
            @states.push(:end_resource_property_elt)
            @resource_node = node_element
          else
            syntax_error("Expected resourcePropertyElt")
          end
        end

        def end_resource_property_elt
          @states.pop
          @block.call(s = Statement.new(@resource_node.parent.parent.subject,
                                        @resource_node.parent.uri,
                                        @resource_node.subject))
          reify(s, @resource_node)
        end

        def literal_property_elt?(event = @current, next_event = peek)
          event.is_a?(ElementEvent) &&
            property_element_uris?(event.uri) &&
            next_event.is_a?(TextEvent)
        end

        def literal_property_elt
          syntax_error("Expected literalPropertyElt") unless literal_property_elt?
          if @current.attributes.any?{|a| ![RDF::ID, RDF::datatype].include?(a.uri)}
            syntax_error("Only rdf:id and rdf:datatype are allowed as properties of literalPropertyElt")
          end

          datatype = @current.has_attribute?(RDF::datatype)
          datatype = datatype && datatype.string_value
          begin
            datatype = datatype && RubyRDF::URINode.new(datatype)
          rescue
            raise SyntaxError, "Literal Datatype is not a valid URI #{datatype}"
          end

          text = @events.shift.string

          if datatype
            @block.call(s = Statement.new(@current.parent.subject,
                                      @current.uri,
                                      TypedLiteral.new(text, datatype)))
          else
            @block.call(s = Statement.new(@current.parent.subject,
                                      @current.uri,
                                      PlainLiteral.new(text, @current.language)))
          end

          reify(s, @current)

          @states.push(:end_element_event)
        end

        def parse_type_literal_property_elt?(event = @current)
          return false unless event.is_a?(ElementEvent)
          a = event.has_attribute?(RDF::parseType)
          a && a.string_value == "Literal"
        end

        def parse_type_literal_property_elt
          if @current.attributes.any?{|a| ![RDF::ID, RDF::parseType].include?(a.uri)}
            syntax_error("Only rdf:id and rdf:datatype are allowed as properties of parseTypeLiteralPropertyElt")
          end

          @states.push(:end_parse_type_literal_property_elt)
          @literal_doc = Nokogiri::XML::DocumentFragment.new(Nokogiri::XML::Document.new)
          @literal_start = @current
          @parse_mode = :literal
        end

        def end_parse_type_literal_property_elt
          @block.call(Statement.new(@literal_start.parent.subject,
                                    @literal_start.uri,
                                    TypedLiteral.new(@literal_doc.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::NO_EMPTY_TAGS),
                                                     RDF::XMLLiteral)))
          @literal_doc = @literal_start = nil
          @parse_mode = :normal
          @states.pop
        end

        def parse_type_resource_property_elt?(event = @current)
          return false unless event.is_a?(ElementEvent)
          a = event.has_attribute?(RDF::parseType)
          a && a.string_value == "Resource"
        end

        def parse_type_resource_property_elt
          if @current.attributes.any?{|a| ![RDF::ID, RDF::parseType].include?(a.uri)}
            syntax_error("Only rdf:id and rdf:datatype are allowed as properties of parseTypeResourcePropertyElt")
          end

          n = @bnodes[RubyRDF.generate_bnode_name] = Object.new
          @block.call(s = Statement.new(@current.parent.subject,
                                        @current.uri,
                                        n))
          reify(s, @current)

          if property_elt_list?(peek, peek(2))
            elt = peek_element
            elt.parent = ElementEvent.new(@current, 'Description', "http://www.w3.org/1999/02/22-rdf-syntax-ns#", [])
            elt.parent.subject = n
            @states.push(:property_elt_list)
          else
            @states.push(:end_element_event)
          end
        end

        def parse_type_collection_property_elt?(event = @current)
          return false unless event.is_a?(ElementEvent)
          a = event.has_attribute?(RDF::parseType)
          a && a.string_value == "Collection"
        end

        def parse_type_collection_property_elt
          if @current.attributes.any?{|a| ![RDF::ID, RDF::parseType].include?(a.uri)}
            syntax_error("Only rdf:id and rdf:datatype are allowed as properties of parseTypeCollectionPropertyElt")
          end

          @last_event = @current
          @states.push(:parse_type_collection_property_elt_first)
        end

        def parse_type_collection_property_elt_first
          if ws?
            ws
          elsif node_element?
            @last_node = Object.new
            @states.pop
            @states.push(:parse_type_collection_property_elt_next)
            n = node_element
            @block.call(s = Statement.new(@last_event.parent.subject,
                                          @last_event.uri,
                                          @last_node))
            reify(s, @last_event)

            @block.call(Statement.new(@last_node,
                                      RDF::first,
                                      @current.subject))
            @last_event = @current
          elsif end_element_event?
            @block.call(s = Statement.new(@current.parent.parent.subject,
                                          @current.parent.uri,
                                          RDF::nil))
            @states.pop
            reify(s, @last_event)
          else
            syntax_error("Expected nodeElementList, not #{@current.inspect}")
          end
        end

        def parse_type_collection_property_elt_next
          if ws?
            ws
          elsif node_element?
            @last_event = node_element
            n = Object.new
            @block.call(Statement.new(n,
                                      RDF::first,
                                      @last_event.subject))
            @block.call(Statement.new(@last_node,
                                      RDF::rest,
                                      n))
            @last_node = n
          elsif end_element_event?
            @block.call(Statement.new(@last_node,
                                      RDF::rest,
                                      RDF::nil))
            @states.pop
          end
        end

        def parse_type_other_property_elt?(event = @current)
          return false unless event.is_a?(ElementEvent)
          a = event.has_attribute?(RDF::parseType)
          a && !["Literal", "Resource", "Collection"].include?(a.string_value)
        end

        def empty_property_elt?(event = @current, next_event = peek)
          event.is_a?(ElementEvent) &&
            property_element_uris?(event.uri) &&
            next_event.is_a?(EndElementEvent)
        end

        def empty_property_elt
          if @current.attributes.empty? ||
              (@current.attributes.size == 1 &&
               (id = @current.rdf_id))
            @block.call(s = Statement.new(@current.parent.subject,
                                          @current.uri,
                                          PlainLiteral.new("", @current.language)))
            reify(s, @current)
          else
            node = nil
            if resource = @current.has_attribute?(RDF::resource)
              node = @current.resolve(resource.string_value)
            end

            if node_id = @current.has_attribute?(RDF::nodeID)
              raise SyntaxError, "Expected only one of rdf:resource or rdf:nodeID" if node
              node = (bnodes[node_id.string_value] ||= Object.new)
            end
            node = @bnodes[RubyRDF.generate_bnode_name] = Object.new unless node

            property_attrs(@current.attributes).each do |a|
              if a.uri == RDF::type
                @block.call(Statement.new(node,
                                          RDF::type,
                                          RubyRDF::URINode.new(a.string_value)))
              else
                @block.call(Statement.new(node,
                                          a.uri,
                                          PlainLiteral.new(a.string_value, @current.language)))
              end
            end

            @block.call(s = Statement.new(@current.parent.subject,
                                          @current.uri,
                                          node))

            reify(s, @current)
          end
          @states.push(:end_element_event)
        end

        def reify(statement, current)
          if id = current.rdf_id
            uri = current.resolve("##{id.string_value}")
            syntax_error("rdf:ID #{uri} is already in use") if @ids.has_key?(uri)
            @ids[uri] = uri
            @block.call(Statement.new(uri, RDF::subject, statement.subject))
            @block.call(Statement.new(uri, RDF::predicate, statement.predicate))
            @block.call(Statement.new(uri, RDF::object, statement.object))
            @block.call(Statement.new(uri, RDF::type, RDF::Statement))
          end
        end
      end
    end
  end
end
