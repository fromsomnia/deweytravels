class GraphsController < ApplicationController
  before_action :authenticate

  def search
    @results = []
    if params[:query].present? then
      @results = @current_graph.search(params[:query])
    end
    respond_to do |format|
      format.html { redirect_to "/graphs/index" }
      format.json { render json: @results }
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def graph_params
      params[:graph]
    end
end
