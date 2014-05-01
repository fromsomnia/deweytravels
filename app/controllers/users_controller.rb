class UsersController < ApplicationController
  before_action :authenticate, except: [:import_google_contacts]
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = []
    if params[:topic_id].present? then
      topic = @current_graph.topics.find(params[:topic_id].to_i)
      if topic != nil then
        @users = topic.experts
      end
    else
      @users = User.all
    end
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { render json: @users }
    end
  end

  def topic_suggestions
    if params[:user_id].present? then
      user = @current_graph.users.find(params[:user_id].to_i)
      if params[:previous_suggestions].present? then
        @topics = Topic.suggestions(user,
                                    params[:previous_suggestions])
      else
        @topics = Topic.suggestions(user)
      end

      render json: @topics
    end
  end

  def sort_by_degree(a, b)
    if a != nil then
      if b != nil then
        return a.degree <=> b.degree
      else
        return 1
      end
    elsif b != nil then
      return -1
    else
      return 0
    end
  end

  # POST
  def add_friends
    friends = params[:friends]
    print @current_user
    @current_user.delay.add_facebook_friends(friends)

    render json: {}, status: :ok
  end

  #max_topics is in params
  #currently returns most connected USERS & TOPICS
  def most_connected
    @nodes = []
    @links = []

    if params[:user_id].present? then
      user = @current_graph.users.find(params[:user_id].to_i)
      if user != nil then
        @nodes += user.expertises
        @nodes += user.friends.sample(20)
      end
    end

    (0..@nodes.length - 1).each do |n|
      link = { :source => @nodes.length,
               :target => n }
      @links << link
    end
    
    @nodes << user

    @result = { :nodes => @nodes, :links => @links }
    print @result
    respond_to do |format|
      format.html { redirect_to @nodes }
      format.json { render json: @result }
    end
  end

  #Adds topic to given user
  #topic_id as payload
  def add_topic
    if params[:topic_id].present? then
      topic = @current_graph.topics.find(params[:topic_id].to_i)
      user = @current_graph.users.find(params[:id])
      if topic != nil && user != nil then
        user.expertises << topic
      end
    end
    render :nothing => true
  end

  #Adds topic to given user
  #topic_id as payload
  def remove_topic
    puts params[:id]
    if params[:topic_id].present? && params[:id].present? then
      user = @current_graph.users.find(params[:id])
      topic = @current_graph.topics.find(params[:topic_id].to_i)
      if topic != nil && user!= nil then
        if user.expertises.include? topic then
          user.expertises.delete(topic)
        end
      end
    end
    render :nothing => true
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = @current_graph.users.find(params[:id])
    respond_to do |format|
      format.html { redirect_to user_url }
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = @current_graph.users.find(params[:id])
    respond_to do |format|
      format.html { redirect_to edit_user_url }
      format.json { render json: @user }
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def import_google_contacts
    contacts = params[:contacts]
    User.delay.import_google_contacts(contacts)
    render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = @current_graph.users.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def user_params
    #   params[:user]
    # end
end
