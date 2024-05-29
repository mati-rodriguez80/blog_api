class PostsController < ApplicationController
  include Secured

  # By convention we use "!" when an action can modify the normal behaviour of a request
  before_action :authenticate_user!, only: [:create, :update]

  # Important: Order Matters! The last rescue_from haves more priority or precedence than the ones above.

  # With Exception (from which all the other classes inherited from) we are handling any exception
  # not described below
  rescue_from Exception do |e|
    # A good practice that could happen in a production environment is to alert. So, we usually can
    # find something like this:
    # log.error "#{e.message}"
    # And, we usually have an error monitor system which would notify people interested in these errors
    render json: { error: e.message }, status: :internal_server_error
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: e.message }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /posts/:id
  def show
    @post = Post.find(params[:id])
    if @post.published? || (Current.user && @post.user_id == Current.user.id)
      render json: @post, status: :ok
    else
      render json: { error: 'Post Not Found' }, status: :not_found
    end
  end

  # GET /posts
  def index
    @posts = Post.where(published: true)
    if !params[:search].nil? && params[:search].present?
      @posts = PostsSearchService.search(@posts, params[:search])
    end
    # ActiveRecord/QueryMethods - includes(*args): Specify associations args to be eager loaded to prevent
    # N + 1 queries. A separate query is performed for each association, unless a join is required by conditions.
    # Rails provides an ActiveRecord method called :includes which loads associated records in advance and
    # limits the number of SQL queries made to the database. This technique is known as "eager loading" and
    # in many cases will improve performance by a significant amount.
    # Time spent for 10 posts of 10 different users: Without includes - 39ms; With includes - 63ms.
    render json: @posts.includes(:user), status: :ok
  end

  # POST /posts
  def create
    # We use create! and update! with "bang!" because we need those methods to fail and throw an exception
    # when the post is invalid or the params are invalid in order to be able to handle these exceptions.
    @post = Current.user.posts.create!(post_params)
    render json: @post, status: :created
  end

  # PUT /posts/:id
  def update
    @post = Current.user.posts.find(params[:id])
    @post.update!(post_params)
    render json: @post, status: :ok
  end

  private

  def post_params
    params.require(:post).permit(:title, :content, :published)
  end
end
