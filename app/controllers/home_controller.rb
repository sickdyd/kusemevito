class HomeController < ApplicationController
  def index
    @client = KubernetesClientService.new
  end
end
