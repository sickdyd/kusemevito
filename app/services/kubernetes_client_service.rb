class KubernetesClientService
  include HTTParty

  DEFAULT_CLUSTER_HOST='localhost'
  DEFAULT_CLUSTER_PORT=6443

  def initialize
    cluster_host = ENV['CLUSTER_HOST'].present? ? ENV['CLUSTER_HOST'] : DEFAULT_CLUSTER_HOST
    cluster_port = ENV['CLUSTER_PORT'] || DEFAULT_CLUSTER_PORT
    base_uri = "https://#{cluster_host}:#{cluster_port}"
    bearer_token = ENV['CLUSTER_SERVICE_ACCOUNT_TOKEN']

    @options = {
      base_uri: base_uri,
      headers: {
        'Authorization' => "Bearer #{bearer_token}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      verify: Rails.env.production? ? true : false
    }
  end

  def nodes
    get("/api/v1/nodes").items
  end

  def namespaces
    get("/api/v1/namespaces").items
  end

  def namespace(name)
    get("/api/v1/namespaces/#{name}")
  end

  def namespaced_deployments(namespace_name)
    get("/apis/apps/v1/namespaces/#{namespace_name}/deployments").items
  end

  def namespaced_ingresses(namespace_name)
    get("/apis/networking.k8s.io/v1/namespaces/#{namespace_name}/ingresses").items
  end

  def namespaced_services(namespace_name, label_selector=nil)
    if label_selector
      get("/api/v1/namespaces/#{namespace_name}/services?labelSelector=#{label_selector}").items
    else
      get("/api/v1/namespaces/#{namespace_name}/services").items
    end
  end

  def namespaced_pods(namespace_name, label_selector=nil)
    if label_selector
      get("/api/v1/namespaces/#{namespace_name}/pods?labelSelector=#{label_selector}").items
    else
      get("/api/v1/namespaces/#{namespace_name}/pods").items
    end
  end

  def get(path)
    response = self.class.get(path, @options)

    if response.code != 200
      raise "#{@options[:base_uri]}#{path} - #{JSON.pretty_generate(JSON.parse(response.body))}"
    else
      JSON.parse(response.body, object_class: OpenStruct)
    end
  end
end
