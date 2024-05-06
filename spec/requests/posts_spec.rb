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
  end

  describe "GET /posts/{id}" do
    let!(:post) { create(:post) }

    it "should return a post" do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload["id"]).to eq(post.id)
      expect(response).to have_http_status(200)
    end
  end
end
