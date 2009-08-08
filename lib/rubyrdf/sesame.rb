require 'net/http'

module RubyRDF
  class Sesame < Graph
    attr_reader :host, :port, :path, :repository

    def initialize(uri, repository) #:nodoc:
      uri = Addressable::URI.parse(uri)
      @host = uri.host
      @port = uri.port
      @path = uri.path
      @repository = repository
      @transactions = []
    end

    def writable? #:nodoc:
      true
    end

    def size #:nodoc:
      get_request(repo_path('size')).read.to_i
    end

    def known?(bnode) #:nodoc:
      false
    end

    def empty? #:nodoc:
      size == 0
    end

    def each(&b) #:nodoc:
      Reader::NTriples.new(get_request(repo_path('statements'), {}, 'Accept' => 'text/plain')).each(&b)
    end

    def add(*statement) #:nodoc:
      if @transactions.any?
        @transactions.last << [:add, statement.to_statement]
      else
        post_request(repo_path('statements'), statement.to_statement.to_ntriples, {}, 'Content-Type' => 'text/plain').read
      end
    end

    def delete(*statement) #:nodoc:
      if @transactions.any?
        @transactions.last << [:delete, statement.to_statement]
      else
        delete_request(repo_path('statements'), to_param_hash(statement.to_statement)).read
      end
    end

    def import(data, format = :ntriples) #:nodoc:
      headers = case format
                when :ntriples
                  {'Content-Type' => 'text/plain; charset=utf-8'}
                when :rdfxml
                  {'Content-Type' => 'application/rdf+xml; charset=utf-8'}
                end

      post_request(repo_path("statements"), data, {}, headers).read
    end

    def delete_all #:nodoc:
      if @transactions.any?
        @transactions.last << [:delete_all, statement.to_statement]
      else
        delete_request(repo_path("statements")).read
      end
    end

    def select(query) #:nodoc:
      SparqlResult.new(get_request(repo_path, {"query" => query}, "Accept" => "application/sparql-results+xml"))
    end

    def ask(query) #:nodoc:
      get_request(repo_path, {"query" => query}, "Accept" => "text/boolean").read == "true"
    end

    def include?(*statement) #:nodoc:
      ask("ASK { #{statement.to_statement.to_ntriples} }")
    end

    # Starts a transaction with Sesame
    def transaction
      @transactions << []
      yield self
      _commit(@transactions.pop)
    rescue => e
      @transactions.pop
      throw e
    end

    # Rolls back the current transaction
    def rollback
      @transactions.pop
      @transactions << []
      true
    end

    # Commits the current transaction
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
      { :subj => node_to_ntriples(statement.subject),
        :pred => node_to_ntriples(statement.predicate),
        :obj => node_to_ntriples(statement.object)}
    end

    #--
    # TODO this needs to be removed, it is not properly encoding unicode characters
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
        "_:bn#{generate_bnode_name}"
      end
    end

    def get_request(path, params = {}, headers = {})
      io = HTTPResponseIO.new
      Thread.start do
        Net::HTTP.start(@host, @port) do |http|
          http.get(format_uri(path, params), headers) do |segment|
            io.append(segment)
          end
          io.eos = true
        end
      end
      io
    end

    def post_request(path, data, params = {}, headers = {})
      io = HTTPResponseIO.new
      Thread.start do
        Net::HTTP.start(@host, @port) do |http|
          http.open_timeout = 6000
          http.read_timeout = 6000
          http.post(format_uri(path, params), data, headers) do |segment|
            io.append(segment)
          end
          io.eos = true
        end
      end
      io
    end

    def delete_request(path, params = {}, headers = {})
      io = HTTPResponseIO.new
      Thread.start do
        Net::HTTP.start(@host, @port) do |http|
          http.delete(format_uri(path, params), headers) do |segment|
            io.append(segment)
          end
          io.eos = true
        end
      end
      io
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
        b.bnode("_:" + (bnodes[node] ||= generate_bnode_name))
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

    def _commit(transaction)
      doc = to_transaction_xml(transaction)
      post_request(repo_path('statements'), doc, {}, 'Content-Type' => 'application/x-rdftransaction').read
    end

    def format_uri(path, params = {})
      if params.empty?
        path
      else
        path + "?" + params.map{|k, v| "#{k}=#{Addressable::URI.escape(v)}"}.join("&")
      end
    end
  end
end
