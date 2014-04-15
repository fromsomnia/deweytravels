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

  #max_topics is in params
  #currently returns most connected USERS & TOPICS
  def most_connected
    @nodes = []
    @links = []
    if params[:user_id].present? then
      user = @current_graph.users.find(params[:user_id].to_i)
      if user != nil then
        @nodes << user
        user.topic_user_connections.each do |tuc|
          expertise = tuc.expertise
          @nodes << expertise
          link = { :source => 0,
                   :target => @nodes.size - 1,
                   :is_upvoted => tuc.is_upvoted_by?(@current_user),
                   :is_downvoted => tuc.is_downvoted_by?(@current_user),
                   :connection => tuc,
                   :connectionType => tuc.class.name}
          @links << link
        end

        user.peers.each do |peer|
          @nodes << peer 
          link = { :source => 0,
                   :target => @nodes.size - 1,
                   :connection => nil }
          @links << link
        end
      end
    end

    @result = { :nodes => @nodes, :links => @links }

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
    contacts.each do |contact|
      # This is a dumb heuristic to filter out
      # bad contacts.
      if (contact['title'].split.size == 2) && (contact['email'].include?('@'))
        user = User.find_by_email(contact['email'])
        if not user
          user = User.new
          contact['title'] = contact['title'].titleize
          user.first_name = contact['title'].split[0]
          user.last_name = contact['title'].split[1]
          user.email = contact['email']
          user.graph = Graph.find_by_domain('google.com')
          user.save
        end
      end

    end

    render :nothing => true
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = @current_graph.users.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user]
    end
end
