module RubyRDF
  module RDFXML
    class Reader
      class Document
        class ElementEvent
          attr_accessor(:parent,
                        :local_name,
                        :namespace_name,
                        :base_uri,
                        :attributes,
                        :uri,
                        :li_counter,
                        :language,
                        :subject)

          def initialize(parent, local_name, namespace_name, attributes)
            @parent = parent
            @local_name = local_name.to_s
            @namespace_name = namespace_name.to_s

            lang = attributes.select do |a|
              "#{a.uri}/#{a.localname}" == XML::lang.uri
            end.first

            base = attributes.select do |a|
              "#{a.uri}/#{a.localname}" == XML::base.uri
            end.first

            @base_uri = if base
                          base = base.value.to_str
                          if base[-1,1] != "/"
                            base + "/"
                          else
                            base
                          end
                        else
                          parent.base_uri
                        end

            @attributes = attributes.delete_if do |a|
              a.prefix.to_s[0,3].downcase == 'xml' ||
              (a.prefix.to_s.strip.size == 0 && a.localname.to_s[0,3].downcase == 'xml')
            end.map{|a| AttributeEvent.new(self, a)}

            @li_counter = 1
            @uri = RubyRDF::URINode.new(@namespace_name + @local_name)

            @language = if lang
                          lang.value.to_s
                        else
                          parent.language
                        end
            @subject = nil
          end

          def resolve(uri)
            uri = uri.to_str
            if base_uri && uri !~ /^[^:]+:\/\//
              RubyRDF::URINode.new(base_uri + uri)
            else
              RubyRDF::URINode.new(uri)
            end
          end

          def has_attribute?(uri)
            a = attributes.select{|a| a.uri == uri}.first
            a if a && a.string_value.present?
          end

          def name_start_char?(c)
            (0x41..0x5A).include?(c) ||
              c == 0x5F ||
              (0x61..0x7A).include?(c) ||
              (0xC0..0xD6).include?(c) ||
              (0xD8..0xF6).include?(c) ||
              (0xF8..0x2FF).include?(c) ||
              (0x370..0x37D).include?(c) ||
              (0x37F..0x1FFF).include?(c) ||
              (0x200C..0x200D).include?(c) ||
              (0x2070..0x218F).include?(c) ||
              (0x2C00..0x2FEF).include?(c) ||
              (0x3001..0xD7FF).include?(c) ||
              (0xF900..0xFDCF).include?(c) ||
              (0xFDF0..0xFFFD).include?(c) ||
              (0x10000..0xEFFFF).include?(c)
          end

          def name_char?(c)
            name_start_char?(c) ||
              c == 0x2D ||
              c == 0x2E ||
              (0x30..0x39).include?(c) ||
              c == 0xB7 ||
              (0x0300..0x036F).include?(c) ||
              (0x203F..0x2040).include?(c)
          end

          def valid_name?(name)
            chars = name.unpack("U*")
            !chars.empty? &&
              name_start_char?(chars.shift) &&
              chars.all?{|c| name_char?(c)}
          end

          def rdf_id
            if id = has_attribute?(RubyRDF::Namespace::RDF::ID)
              if valid_name?(id.string_value)
                id
              else
                raise SyntaxError, "rdf:ID must match the XML Name production (as modified by XML namespaces)"
              end
            end
          end

          def inspect
            content = []
            content << parent.uri if parent && parent.respond_to?(:uri)
            content << uri
            "#<ElementEvent #{content.join(" ")}>"
          end
        end
      end
    end
  end
end
