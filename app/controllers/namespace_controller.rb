class NamespaceController < ApplicationController
  def show
    @client = KubernetesClientService.new
    @namespace = @client.namespace(params[:name])
    @ingresses = @client.ingresses(params[:name])
    @services = @client.services(params[:name])
    @pods = @client.pods(params[:name])

    pp @ingresses[0]
  end
end
