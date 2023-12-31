class KubernetesClientService
  include HTTParty

  CLUSTER_HOST = ENV['CLUSTER_HOST'].present? ? ENV['CLUSTER_HOST'] : '127.0.0.1'
  CLUSTER_PORT= ENV['CLUSTER_PORT'] || 6443
  CLUSTER_BASE_URI = "https://#{CLUSTER_HOST}:#{CLUSTER_PORT}"
  CLUSTER_SERVICE_ACCOUNT_TOKEN = ENV['CLUSTER_SERVICE_ACCOUNT_TOKEN']

  def initialize
    @options = {
      base_uri: CLUSTER_BASE_URI,
      headers: {
        'Authorization' => "Bearer #{CLUSTER_SERVICE_ACCOUNT_TOKEN}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Accept-Encoding' => 'gzip'
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
    get("/api/v1/namespaces/#{namespace_name}/services?labelSelector=#{label_selector}").items
  end

  def namespaced_pods(namespace_name, label_selector=nil)
    get("/api/v1/namespaces/#{namespace_name}/pods?labelSelector=#{label_selector}").items
  end

  def namespaced_pods_resource_version(namespace_name, label_selector=nil)
    get("/api/v1/namespaces/#{namespace_name}/pods?labelSelector=#{label_selector}").metadata.resourceVersion
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
