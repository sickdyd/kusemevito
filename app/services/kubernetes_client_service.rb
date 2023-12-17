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

  private

  def get(path)
    response = self.class.get(path, @options)
    JSON.parse(response.body, object_class: OpenStruct)
  end
end
