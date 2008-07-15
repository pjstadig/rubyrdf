module RDF
  class Sesame
    class Version2
      attr_reader :address, :port, :path, :repository
      
      def initialize(uri, repository)
        uri = URI.parse(uri)
        @address = uri.host
        @port = uri.port
        @path = uri.path
        @repository = repository
      end
      
      def size
        get_request(repo_path('size')).to_i
      end
      
      def empty?
        size == 0
      end
      
      def add(*statement)
        post_request(repo_path('statements'), statement.to_statement.to_ntriples, {}, 'Content-Type' => 'text/plain')
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
        delete_request(repo_path('statements'), to_param_hash(statement.to_statement))
      end
      
      def delete_all
        delete_request(repo_path("statements"))
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
      
      private
      def repo_path(path = nil)
        parts = [@path, "repositories", @repository]
        if path.to_s.strip != ""
          parts << path
        end
        
        File.join(*parts)
      end
      
      def to_param_hash(statement)
        {:subj => statement.subject.to_ntriples,
         :pred => statement.predicate.to_ntriples,
         :obj => statement.object.to_ntriples}
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
      
      def format_uri(path, params = {})
        if params.empty?
          path
        else
          path + "?" + params.map{|k, v| "#{k}=#{URI.escape(v)}"}.join("&")
        end
      end
    end
  end
end