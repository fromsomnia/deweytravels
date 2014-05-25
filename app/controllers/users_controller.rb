class UsersController < ApplicationController
  before_action :authenticate, except: [:import_google_contacts, :show, :most_connected]
  before_action :authenticate_without_401, only: [:show, :most_connected]
  before_action :set_user, only: [:edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = []
    if params[:topic_id].present? then
      topic = @current_graph.topics.find(params[:topic_id].to_i)
      if topic != nil then
        @users = topic.experts_which_friends_with(@current_user)
        if topic.experts.include?(@current_user)
          @users << @current_user
        end
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
    @current_user.delay.add_facebook_friends(friends)
    mixpanel.track 'add_facebook_friends', {
          :uid => @current_user.id,
          :num_friends => friends.length
        }

    render json: {}, status: :ok
  end

  # max_topics is in params
  # currently returns most connected USERS & TOPICS
  def most_connected
    @nodes = []
    @links = []

    @nodes = []
    @links = []

    max_topics = params[:max_topics].present? ? params[:max_topics].to_i : 10
    max_users = params[:max_users].present? ? params[:max_users].to_i : 10

    if params[:user_id].present? then
      user = User.find(params[:user_id].to_i)
      if user != nil then
        degree = user.degree
        user.expertises.each do |expertise|
          if expertise.degree == degree then
            @nodes << expertise
          end
        end
        @nodes += user.friends_on_site.sample(max_users)
      end
    end

    (0..@nodes.length - 1).each do |n|
      link = { :source => @nodes.length,
               :target => n }
      @links << link
    end
    
    @nodes << user

    @result = { :nodes => @nodes, :links => @links }
    respond_to do |format|
      format.html { redirect_to @nodes }
      format.json { render json: @result }
    end
  end

  # Gets friends of given user
  def friends
    @friends = []
    if params[:id].present? then
      user = User.find(params[:id].to_i)
      if user then
        @friends = user.friends
      end
    end
    respond_to do |format|
      format.html { redirect_to @friends }
      format.json { render json: @friends }
    end
  end

  # Adds topic to given user
  # topic_id as payload
  def add_topic
    if params[:topic_id].present? then
      topic = @current_graph.topics.find(params[:topic_id].to_i)
      user = @current_graph.users.find(params[:id].to_i)
      if topic != nil && user != nil then

        mixpanel.track 'add_topic_to_user', {
            :uid => @current_user.id,
            :tid => topic.id,
            :topic_name => topic.title
          }
        user.expertises << topic
      end
    end
    render :nothing => true
  end

  # Adds topic to given user
  # topic_id as payload
  def remove_topic
    if params[:topic_id].present? && params[:id].present? then
      user = @current_graph.users.find(params[:id].to_i)
      topic = @current_graph.topics.find(params[:topic_id].to_i)
      if topic != nil && user!= nil then
        if user.expertises.include? topic then

          mixpanel.track 'remove_topic_from_user', {
              :uid => user.id,
              :tid => topic.id,
              :topic_name => topic.title
            }
          user.expertises.delete(topic)
        end
      end
    end
    render :nothing => true
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id].to_i)
    if !@current_user then
      @user.email = nil
    end
    respond_to do |format|
      format.html { redirect_to user_url }
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = @current_graph.users.find(params[:id].to_i)
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
      @user = @current_graph.users.find(params[:id].to_i)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    # def user_params
    #   params[:user]
    # end
end
