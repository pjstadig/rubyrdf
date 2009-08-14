module RubyRDF
  #--
  # TODO document
  # TODO specs
  # TODO name?
  # TODO split out HttpGraph
  class SparqlEndpoint < Graph
    attr_reader :endpoint_uri
    attr_reader :default_graph_uri
    attr_reader :named_graph_uri

    def initialize(endpoint_uri, default_graph_uri = nil, named_graph_uri = nil)
      @endpoint_uri = Addressable::URI.parse(endpoint_uri.to_s)
      @default_graph_uri = default_graph_uri
      @named_graph_uri = named_graph_uri
    end

    def known?(bnode)
      false
    end

    def query(query, options = nil)
      if query.is_a?(Query)
        super
      else
        query_sparql(query, options)
      end
    end

    private
    def query_sparql(query, options = nil)
      options = {:method => 'get'}.merge(options || {})
      params = {:query => query}
      params['default-graph-uri'] = default_graph_uri if default_graph_uri
      params['named-graph-uri'] = named_graph_uri if named_graph_uri
      SparqlResult.new(if options[:method].to_s.downcase == 'get'
                         get_request(params)
                       elsif options[:method].to_s.downcase == 'post'
                         post_request(params)
                       else
                         raise "Unknown HTTP method"
                       end)
    end

    def get_request(params = {}, headers = {})
      io = HTTPResponseIO.new
      Thread.start do
        Net::HTTP.start(@endpoint_uri.host, @endpoint_uri.port) do |http|
          http.get(format_uri(@endpoint_uri.path, params), headers) do |segment|
            io.append(segment)
          end
          io.eos = true
        end
      end
      puts io.read
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

    def format_uri(path, params = {})
      if params.empty?
        path
      else
        path + "?" + params.map{|k, v| "#{k}=#{Addressable::URI.escape(v)}"}.join("&")
      end
    end
  end
end
