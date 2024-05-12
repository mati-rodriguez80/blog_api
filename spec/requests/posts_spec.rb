require "rails_helper"

RSpec.describe "Posts", type: :request do
  describe "GET /posts" do
    describe "without data in the DB" do
      it "should return OK" do
        get '/posts'
        payload = JSON.parse(response.body)
        expect(payload).to be_empty
        expect(response).to have_http_status(200)
      end
    end

    describe "with data in the DB" do
      # let(:posts) {} is used to declared a variable called posts in this case, which it's going to
      # have assigned what we have within the block {}. Then, this variable is going to be available
      # to be used inside our tests. "let() {}" comes from RSpec.
      # create_list() comes from FactoryBot.
      let!(:posts) { create_list(:post, 10, published: true) }
      # let uses the lazy loading strategy. This means that it's not going to create posts until is
      # being used in line expect(payload.size).to eq(posts.size). That's why we use let! here to
      # create posts right away.

      it "should return all published posts" do
        get '/posts'
        payload = JSON.parse(response.body)
        expect(payload.size).to eq(posts.size)
        expect(response).to have_http_status(200)
      end
    end

    describe "Search" do
      let!(:hello_world_post) { create(:published_post, title: "Hello World") }
      let!(:hello_rails_post) { create(:published_post, title: "Hello Rails") }
      let!(:rails_course_post) { create(:published_post, title: "Rails Course") }

      it "should filter posts by title" do
        get '/posts?search=Hello'
        payload = JSON.parse(response.body)
        expect(payload).not_to be_empty
        expect(payload.size).to eq(2)
        expect(payload.map { |post| post["id"] }.sort).to eq([hello_world_post.id, hello_rails_post.id].sort)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET /posts/{id}" do
    let!(:post) { create(:post) }

    it "should return a post" do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      # After including ActiveModelSerializers, we are going to specify the new format about
      # how a post should be serialized
      expect(payload["id"]).to eq(post.id)
      expect(payload["title"]).to eq(post.title)
      expect(payload["content"]).to eq(post.content)
      expect(payload["published"]).to eq(post.published)
      expect(payload["author"]["name"]).to eq(post.user.name)
      expect(payload["author"]["email"]).to eq(post.user.email)
      expect(payload["author"]["id"]).to eq(post.user.id)
      expect(response).to have_http_status(200)
    end
  end

  describe "POST /posts" do
    let!(:user) { create(:user) }

    it "should create a post" do
      req_payload = {
        post: {
          title: "Title",
          content: "Content",
          published: false,
          user_id: user.id
        }
      }
      post "/posts", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).not_to be_nil
      expect(response).to have_http_status(:created) # 201
    end

    it "should return an error message on invalid post" do
      req_payload = {
        post: {
          content: "Content",
          published: false,
          user_id: user.id
        }
      }
      post "/posts", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["error"]).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity) # 422
    end
  end

  describe "PUT /posts/{id}" do
    let!(:post) { create(:post) }

    it "should edit a post" do
      req_payload = {
        post: {
          title: "Title",
          content: "Content",
          published: true
        }
      }
      put "/posts/#{post.id}", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(post.id)
      expect(response).to have_http_status(:ok) # 200
    end

    it "should return an error message on invalid post" do
      req_payload = {
        post: {
          title: nil,
          content: nil,
          published: true
        }
      }
      put "/posts/#{post.id}", params: req_payload
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["error"]).not_to be_empty
      expect(response).to have_http_status(:unprocessable_entity) # 422
    end
  end
end
