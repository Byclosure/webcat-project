require 'net/http'
require 'httparty'

class BuildController < ApplicationController
  def show
    @build = Build.find(params[:id])

    render json: @build.inspect
  end

  def delete
    @build = Build.find(params[:id])

    @build.destroy

    redirect_to build_path
  end

  def index
    @build = Build.last
  end

end
