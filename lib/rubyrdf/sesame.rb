require 'uri'
require 'net/http'

# TODO use Addressable instead of URI
module RubyRDF
  class Sesame < Graph
    attr_reader :address, :port, :path, :repository

    def initialize(uri, repository)
      uri = URI.parse(uri)
      @address = uri.host
      @port = uri.port
      @path = uri.path
      @repository = repository
      @transactions = []
    end

    def size
      get_request(repo_path('size')).to_i
    end

    def empty?
      size == 0
    end

    def add(*statement)
      if @transactions.any?
        @transactions.last << [:add, statement.to_statement]
      else
        post_request(repo_path('statements'), statement.to_statement.to_ntriples, {}, 'Content-Type' => 'text/plain')
      end
    end

    def import(data, format = :ntriples)
      headers = case format
      when :ntriples
        {'Content-Type' => 'text/plain; charset=utf-8'}
      when :rdfxml
        {'Content-Type' => 'application/rdf+xml; charset=utf-8'}
      end

      result = post_request(repo_path("statements"), data, {}, headers)
      result
    end

    def delete(*statement)
      if @transactions.any?
        @transactions.last << [:delete, statement.to_statement]
      else
        delete_request(repo_path('statements'), to_param_hash(statement.to_statement))
      end
    end

    def delete_all
      if @transactions.any?
        @transactions.last << [:delete_all, statement.to_statement]
      else
        delete_request(repo_path("statements"))
      end
    end

    def select(query)
      SparqlResult.new(get_request(repo_path, {"query" => query}, "Accept" => "application/sparql-results+xml"))
    end

    def ask(query)
      get_request(repo_path, {"query" => query}, "Accept" => "text/boolean") == "true"
    end

    def include?(*statement)
      ask("ASK { #{statement.to_statement.to_ntriples} }")
    end

    def transaction
      @transactions << []
      yield self
      _commit(@transactions.pop)
    rescue => e
      @transactions.pop
      throw e
    end

    def rollback
      @transactions.pop
      @transactions << []
      true
    end

    def commit
      _commit(@transactions.pop)
      @transactions << []
      true
    end

    private
    def repo_path(path = nil)
      parts = [@path, "repositories", @repository]
      if path.to_s.strip != ""
        parts << path
      end

      File.join(*parts)
    end

    def to_param_hash(statement)
      {:subj => node_to_ntriples(statement.subject),
       :pred => node_to_ntriples(statement.predicate),
       :obj => node_to_ntriples(statement.object)}
    end

    def node_to_ntriples(node)
      case node
      when Addressable::URI
        "<#{node}>"
      when TypedLiteral
        %Q("#{node.lexical_form}"^^<#{node.datatype_uri}>)
      when PlainLiteral
        %Q("#{node.lexical_form}") +
          (node.language_tag ? "@#{node.language_tag}" : "")
      else
        "_:bn#{Digest::MD5.hexdigest(Time.now.to_s)}"
      end
    end

    def get_request(path, params = {}, headers = {})
      Net::HTTP.start(@address, @port) do |http|
        http.get(
          format_uri(path, params),
          headers).body
      end
    end

    def post_request(path, data, params = {}, headers = {})
      Net::HTTP.start(@address, @port) do |http|
        http.open_timeout = 6000
        http.read_timeout = 6000
        http.post(format_uri(path, params), data, headers).body
      end
    end

    def delete_request(path, params = {}, headers = {})
      Net::HTTP.start(@address, @port) do |http|
        http.delete(format_uri(path, params), headers).body
      end
    end

    def to_transaction_xml(transaction)
      bnodes = {}
      b = Builder::XmlMarkup.new
      b.transaction do
        transaction.each do |op|
          if op[0] == :add
            b.add do
              transaction_xml_nodes(b, op[1], bnodes)
            end
          elsif op[0] == :delete
            b.remove do
              transaction_xml_nodes(b, op[1], bnodes)
            end
          elsif op[0] == :delete_all
            b.clear
          end
        end
      end
      b.target!
    end

    def transaction_xml_nodes(b, stmt, bnodes)
      transaction_xml_node(b, stmt.subject, bnodes)
      transaction_xml_node(b, stmt.predicate, bnodes)
      transaction_xml_node(b, stmt.object, bnodes)
    end

    def transaction_xml_node(b, node, bnodes)
      if node.is_a?(Addressable::URI)
        b.uri(node.to_s)
      elsif bnode?(node)
        b.bnode(bnodes[node] ||= generate_bnode_name)
      elsif node.is_a?(TypedLiteral)
        b.literal(node.lexical_form, :datatype => node.datatype_uri)
      elsif node.is_a?(PlainLiteral)
        attrs = {}
        if node.language_tag
          attrs[:"xml:lang"] = node.language_tag
        end

        b.literal(node.lexical_form, attrs)
      end
    end

    def generate_bnode_name
      "_:bn#{Digest::MD5.hexdigest(Time.now.to_s)}"
    end

    def _commit(transaction)
      doc = to_transaction_xml(transaction)
      post_request(repo_path('statements'), doc, {}, 'Content-Type' => 'application/x-rdftransaction')
    end

    def format_uri(path, params = {})
      if params.empty?
        path
      else
        path + "?" + params.map{|k, v| "#{k}=#{URI.escape(v)}"}.join("&")
      end
    end
  end
end