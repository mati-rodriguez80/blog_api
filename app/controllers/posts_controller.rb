class PostsController < ApplicationController
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

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # GET /posts/:id
  def show
    @post = Post.find(params[:id])
    render json: @post, status: :ok
  end

  # GET /posts
  def index
    @posts = Post.where(published: true)
    render json: @posts, status: :ok
  end

  # POST /posts
  def create
    # We use create! and update! with "bang!" because we need those methods to fail and throw an exception
    # when the post is invalid or the params are invalid in order to be able to handle these exceptions.
    @post = Post.create!(post_params_create)
    render json: @post, status: :created
  end

  # PUT /posts/:id
  def update
    @post = Post.find(params[:id])
    @post.update!(post_params_update)
    render json: @post, status: :ok
  end

  private

  def post_params_create
    # We are permitting user_id temporarily until we have authentication
    params.require(:post).permit(:title, :content, :published, :user_id)
  end

  def post_params_update
    params.require(:post).permit(:title, :content, :published)
  end
end
