class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = []
    if params[:user_id].present? then
      user = User.find(params[:user_id].to_i)
      if user != nil then
        @groups = user.groups
      else
        @groups = Group.all
      end
    else
      @groups = Group.all
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { render json: @users }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render action: 'show', status: :created, location: @group }
      else
        format.html { render action: 'new' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end

  #Adds user to given group
  #user_id as payload
  def add_user
    if params[:group_id].present? then
      group = Group.find(params[:group_id].to_i)
      if params[:id].present? then
        user = User.find(params[:id])
        if group != nil && user != nil then
          if !group.users.include? user then
            group.users << user
          end
        end
      end
    end
    render :nothing => true
  end

  #Removes user group given group
  #user_id as payload
  def remove_user
    if params[:group_id].present? then
      group = Group.find(params[:group_id].to_i)
      if params[:id].present? then
        user = User.find(params[:id])
        if group != nil && user != nil then
          if group.users.include? user then
            group.users.delete(user)
          end
        end
      end
    end
    render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params[:group]
    end
end
