class InvitesController < ApplicationController
  before_action :authenticate

  # POST /invites
  def create
    @invite = Invite.new

    @invite.inviter = @current_user
    @invite.email = params[:email]
    # @invite.group_id = params[:group_id]
    if @invite.save
      # TODO: send_email
      render :nothing => true
    end
  end

end
