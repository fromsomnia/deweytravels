class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :update, :destroy]

  # GET /topics
  # GET /topics.json
  def index
    @topics = []
    if params[:user_id].present? then
      user = User.find(params[:user_id].to_i)
      if user != nil then
        @topics = user.expertises
      end
    else
      @topics = Topic.all
    end
    respond_to do |format|
      format.html { redirect_to topics_url }
      format.json { render json: @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.json
  def show
    @topic = Topic.find(params[:id])
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
    @topic = Topic.find(params[:id])
    respond_to do |format|
      format.html { redirect_to edit_topic_url }
      format.json { render json: @topic }
    end
  end

  #Adds user to given topic
  #user_id as payload
  def add_user
    if params[:id].present? then
      current_topic = Topic.find(params[:id])
      user = User.find(params[:user_id])
      if current_topic != nil && user != nil then
        current_topic.experts << user
      end
    end
    render :nothing => true
  end

  #Removes user from topic
  #user_id as payload
  def remove_user
     if params[:id].present? then
      current_topic = Topic.find(params[:id])
      user = User.find(params[:user_id])
      if current_topic != nil && user != nil then
        current_topic.users.delete(user)
      end
    end
    render :nothing => true
  end

  #returns related topics (same parents)
  def related
    @topics = []
    if params[:id].present? then
      topic = Topic.find(params[:id].to_i)
      if topic != nil then
        topic.supertopics.each do |supertopic|
          supertopic.subtopics.each do |tiq|
            if !related.include?(tiq) then
              related << tiq
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
      topic = Topic.find(params[:id].to_i)
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
      topic = Topic.find(params[:id].to_i)
      if topic != nil then
        @topics = topic.supertopics
      end
    end
    respond_to do |format|
      format.html { redirect_to @topics }
      format.json { render json: @topics }
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
    if params[:topic_id].present? then
      topic = Topic.find(params[:topic_id].to_i)
      if topic != nil then
        @nodes << topic
        topic.supertopics.each do |supertopic|
          if !@nodes.include?(supertopic) then
            @nodes << supertopic
            link = { :source => 0, :target => @nodes.size}
            @links << link
          end
        end
        topic.subtopics.each do |subtopic|
          if !@nodes.include?(subtopic) then
            @nodes << subtopic
            link = { :source => 0, :target => @nodes.size}
            @links << link
          end
        end
      end
      topic.experts.each do |expert|
        @nodes << expert
        link = { :source => 0, :target => @nodes.size}
        @links << link
      end
    end
    result = { :nodes => @nodes, :links => @links }

    respond_to do |format|
      format.html { redirect_to @nodes }
      format.json { render json: result }
    end
  end

  def add_subtopic
    if params[:id].present? && params[:topic_id2].present? then
      topic = Topic.find(params[:id].to_i)
      subtopic = Topic.find(params[:topic_id2].to_i)
      if topic != nil && subtopic != nil then
        topic.subtopics << subtopic
      end
    end
    render :nothing => true
  end

  #topic_id2 as payload
  def add_supertopic
    if params[:id].present? && params[:topic_id2].present? then
      topic = Topic.find(params[:id].to_i)
      supertopic = Topic.find(params[:topic_id2].to_i)
      if topic != nil && supertopic != nil then
        topic.supertopics << supertopic
      end
    end
    render :nothing => true
  end

  #topic_id2 as payload
  def remove_subtopic
    if params[:id].present? && params[:topic_id2].present? then
      topic = Topic.find(params[:id].to_i)
      subtopic = Topic.find(params[:topic_id2].to_i)
      if topic != nil && subtopic != nil then
        if topic.subtopics.include?(subtopic) then
          topic.subtopics.delete(subtopic)
        end
      end
    end
    render :nothing => true
  end

  #topic_id2 as payload
  def remove_supertopic
    if params[:id].present? && params[:topic_id2].present? then
      current_topic = Topic.find(params[:id].to_i)
      to_remove = Topic.find(params[:topic_id2].to_i)
      if current_topic != nil && to_remove != nil then
        if current_topic.supertopics.include?(to_remove) then
          current_topic.supertopics.delete(to_remove)
        end
      end
    end
    render :nothing => true
  end

  # POST /topics
  # POST /topics.json
  def create
    @topic = Topic.new(topic_params)

    respond_to do |format|
      if @topic.save
        format.html { redirect_to @topic, notice: 'Topic was successfully created.' }
        format.json { render action: 'show', status: :created, location: @topic }
      else
        format.html { render action: 'new' }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
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
