class TopicsController < ApplicationController
  before_action :authenticate, except: [:show, :related, :most_connected]
  before_action :authenticate_without_401, only: [:show, :related, :most_connected]
  before_action :set_topic, only: [:show, :edit, :update, :destroy]


  # GET /topics
  # GET /topics.json
  def index
    @topics = []
    if params[:user_id].present? then
      user = @current_graph.users.find(params[:user_id].to_i)
      if user != nil then
        @topics = user.expertises
      end
    else
      @topics = @current_graph.topics
    end
    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { render json: @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    respond_to do |format|
      format.html { redirect_to topic_url }
      format.json { render json: @topic }
    end
  end


  # GET /topics/new
  def new
    @topic = Topic.new
  end

  # GET /topics/1/edit
  def edit
    @topic = @current_graph.topics.find(params[:id])
    respond_to do |format|
      format.html { redirect_to edit_topic_url }
      format.json { render json: @topic }
    end
  end

  # Adds user to given topic
  # user_id as payload
  def add_user
    if params[:id].present? then
      current_topic = @current_graph.topics.find(params[:id])
      user = @current_graph.users.find(params[:user_id].to_i)
      if current_topic != nil && user != nil then
        mixpanel.track 'add_user_to_topic', {
          :uid => user.id,
          :tid => current_topic.id,
          :topic_name => current_topic.title
        }
        current_topic.experts << user
      end
    end
    render :nothing => true
  end

  #Removes user from topic
  #user_id as payload
  def remove_user
     if params[:id].present? then
      current_topic = @current_graph.topics.find(params[:id])
      user = @current_graph.users.find(params[:user_id].to_i)
      if current_topic != nil && user != nil then
        mixpanel.track 'remove_user_from_topic', {
          :uid => user.id,
          :tid => current_topic.id,
          :topic_name => current_topic.title
        }

        current_topic.experts.delete(user)
      end
    end
    render :nothing => true
  end

  #returns related topics (same parents)
  def related
    @topics = []
    if params[:topic_id].present? then
      topic = Topic.find(params[:topic_id].to_i)
      if topic then
        topic.supertopics.each do |supertopic|
          supertopic.subtopics.each do |tiq|
            if !@topics.include?(tiq) then
              @topics << tiq
            end
          end
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to @topics }
      format.json { render json: @topics }
    end
  end

  def subtopics
    @topics = []
    if params[:id].present then
      topic = @current_graph.topics.find(params[:id].to_i)
      if topic != nil then
        @topics = topic.subtopics
      end
    end
    respond_to do |format|
      format.html { redirect_to @topics }
      format.json { render json: @topics }
    end
  end

  def supertopics
    @topics = []
    if params[:id].present then
      topic = @current_graph.topics.find(params[:id].to_i)
      if topic != nil then
        @topics = topic.supertopics
      end
    end
    respond_to do |format|
      format.html { redirect_to @topics }
      format.json { render json: @topics }
    end
  end

  #max_topics is in params
  #currently returns most connected USERS & TOPICS
  def most_connected
    @nodes = []
    @links = []

    max_topics = params[:max_topics].present? ? params[:max_topics].to_i : 10
    max_users = params[:max_users].present? ? params[:max_users].to_i : 10


    if params[:user_id].present? && params[:topic_id].present? then
      user = User.find(params[:user_id].to_i)
      topic = Topic.find(params[:topic_id].to_i)
      @nodes += (user.expertises & topic.subtopics).take(max_topics)
    elsif params[:topic_id].present? then
      topic = Topic.find(params[:topic_id].to_i)
      @nodes += topic.subtopics.take(max_topics - 1)
      @nodes += topic.supertopics
      if @current_user then
        @nodes = topic.experts_which_friends_with(@current_user, only_registered=true).take(max_users)
        if topic.experts.include?(@current_user)
          @nodes << @current_user
        end
      end
    end
    result = { :nodes => @nodes, :links => @links }

    (0..@nodes.length - 1).each do |n|
      link = { :source => @nodes.length,
               :target => n }
      @links << link
    end
    
    @nodes << topic
    respond_to do |format|
      format.html { redirect_to @nodes }
      format.json { render json: result }
    end
  end

  def add_subtopic
    if params[:id].present? && params[:topic_id2].present? then
      topic = @current_graph.topics.find(params[:id].to_i)
      subtopic = @current_graph.topics.find(params[:topic_id2].to_i)
      if topic != nil && subtopic != nil then
        mixpanel.track 'add_subtopic', {
          :supertopic_id => topic.id,
          :subtopic_id => subtopic.id,
          :supertopic_name => topic.title,
          :subtopic_name => subtopic.title }
        topic.subtopics << subtopic
      end
    end
    render :nothing => true
  end

  #topic_id2 as payload
  def add_supertopic
    if params[:id].present? && params[:topic_id2].present? then
      topic = @current_graph.topics.find(params[:id].to_i)
      supertopic = @current_graph.topics.find(params[:topic_id2].to_i)
      if topic != nil && supertopic != nil then
        mixpanel.track 'add_supertopic', {
          :subtopic_id => topic.id,
          :supertopic_id => supertopic.id,
          :subtopic_name => topic.title,
          :supertopic_name => supertopic.title }
        topic.supertopics << supertopic
      end
    end
    render :nothing => true
  end

  #topic_id2 as payload
  def remove_subtopic
    if params[:id].present? && params[:topic_id2].present? then
      topic = @current_graph.topics.find(params[:id].to_i)
      subtopic = @current_graph.topics.find(params[:topic_id2].to_i)
      if topic != nil && subtopic != nil then
        if topic.subtopics.include?(subtopic) then
          mixpanel.track 'remove_subtopic', {
            :supertopic_id => topic.id,
            :subtopic_id => subtopic.id,
            :supertopic_name => topic.title,
            :subtopic_name => subtopic.title }
          topic.subtopics.delete(subtopic)
        end
      end
    end
    render :nothing => true
  end

  #topic_id2 as payload
  def remove_supertopic
    if params[:id].present? && params[:topic_id2].present? then
      current_topic = @current_graph.topics.find(params[:id].to_i)
      to_remove = @current_graph.topics.find(params[:topic_id2].to_i)
      if current_topic != nil && to_remove != nil then
        if current_topic.supertopics.include?(to_remove) then

          mixpanel.track 'remove_supertopic', {
            :subtopic_id => current_topic.id,
            :supertopic_id => to_remove.id,
            :subtopic_name => current_topic.title,
            :supertopic_name => to_remove.title }
          current_topic.supertopics.delete(to_remove)
        end
      end
    end
    render :nothing => true
  end

  # POST /topics
  # POST /topics.json
  def create
    # Note from veni to implementor: don't forget to make this
    # domain spec.
   if topic_params[:parent_id].present? then
      super_topic = @current_graph.topics.find(topic_params[:parent_id])
      if super_topic != nil && !super_topic.subtopics.map{|topic| topic.title}.include?(topic_params[:title]) then
        @topic = Topic.new
        @topic.title = topic_params[:title]
        @topic.graph = super_topic.graph
        respond_to do |format|
          if @topic.save

            mixpanel.track 'create_topic', {
              :topic_id => @topic.id,
              :topic_name => @topic.title,
              :supertopic_id => super_topic.id,
              :supertopic_name => super_topic.title }
            @topic.supertopics << super_topic
            format.html { redirect_to @topic, notice: 'Topic was successfully created.' }
            format.json { render json: @topic }
          else
            format.html { render action: 'new' }
            format.json { render json: @topic.errors, status: :unprocessable_entity }
          end
        end
      end
    end
  end

  # PATCH/PUT /topics/1
  # PATCH/PUT /topics/1.json
  def update
    respond_to do |format|
      if @topic.update(topic_params)
        format.html { redirect_to @topic, notice: 'Topic was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic.destroy
    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { head :no_content }
    end
  end

  def user_suggestions
    if params[:topic_id].present? then
      topic = @current_graph.topics.find(params[:topic_id].to_i)
      if params[:previous_suggestions].present? then
        @users = User.suggestions(topic,
                                    @current_user,
                                    params[:previous_suggestions])
      else
        @users = User.suggestions(topic, @current_user)
      end
      render json: @users
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      @topic = Topic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def topic_params
      params[:topic]
    end
end
