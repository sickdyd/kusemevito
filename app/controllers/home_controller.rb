# this controller handles hte index page
# Path: app/controllers/home_controller.rb
# class HomeController < ApplicationController
class HomeController < ApplicationController
  def index
    @client = KubernetesClientService.new
  end
end
