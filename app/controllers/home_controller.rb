class HomeController < ApplicationController
  def index
    @client = KubernetesClientService.new

    k8s_graph = GraphService.new
    k8s_graph.graph.write_to_graphic_file('png', 'public/graphs/graph')
  end
end
