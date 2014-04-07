class ConnectionsController < ApplicationController

  before_action :set_connection, only: [:show, :edit, :update, :destroy]

  def upvote
    @connection_type = params[:connection_type]
    @connection_id = params[:id]
    
    connClass = Object.const_get(@connection_type)
    if (connClass)
      # TODO(veni): change User.first to current_user
      # when login is correctly implemented
      connClass.find(@connection_id).upvoted_by(User.first)
    end
    render :nothing => true
  end

  def downvote
    @connection_type = params[:connection_type]
    @connection_id = params[:id]
    
    connClass = Object.const_get(@connection_type)
    if (connClass)
      # TODO(veni): change User.first to current_user
      # when login is correctly implemented
      connClass.find(@connection_id).downvoted_by(User.first)
    end
    render :nothing => true
  end

  def index

  end
end
