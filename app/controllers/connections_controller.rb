class ConnectionsController < ApplicationController

  before_action :set_connection, only: [:show, :edit, :update, :destroy]
  before_action :authenticate

  def upvote
    @connection_type = params[:connection_type]
    @connection_id = params[:id]
    
    connClass = Object.const_get(@connection_type)
    if (connClass)
      connClass.find(@connection_id).upvoted_by(@current_user)
    end
    render :nothing => true
  end

  def downvote
    @connection_type = params[:connection_type]
    @connection_id = params[:id]
    
    connClass = Object.const_get(@connection_type)
    if (connClass)
      connClass.find(@connection_id).downvoted_by(@current_user)
    end
    render :nothing => true
  end

  def index

  end
end
