require "rails_helper"

RSpec.describe "Posts with authentication", type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:user_post) { create(:post, user_id: user.id) }
  let!(:other_user_post) { create(:post, user_id: other_user.id, published: true) }
  let!(:other_user_post_draft) { create(:post, user_id: other_user.id, published: false) }
  # Requests with authentication in HTTP usually works sending an additional header where a token is
  # specified. By convention, the header is as follows: Authorization: Bearer xxxxx (xxxxx = token).
  # This is usually the standard for known providers like AuthO.
  let!(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }
  let!(:other_auth_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }
  let!(:create_params) { { "post" => { "title" => "Title", "content" => "Content", "published" => true } } }
  let!(:invalid_create_params) { { "post" => { "content" => "Content", "published" => true } } }
  let!(:update_params) { { "post" => { "title" => "Title", "content" => "Content", "published" => true } } }
  let!(:invalid_update_params) { { "post" => { "title" => nil, "content" => nil, "published" => true } } }

  describe "GET /posts/{id}" do
    context "with valid auth" do
      context "when requesting other's author post" do
        context "when post is public" do
          before { get "/posts/#{other_user_post.id}", headers: auth_headers }

          context "payload" do
            # New topic: we can provide a test subject. From stackoverflow: The subject is the object
            # being tested. RSpec has an explicit idea of the subject. It may or may not be defined.
            # If it is, RSpec can call methods on it without referring to it explicitly. Expectations
            # can be set on it implicitly (without writing subject or the name of a named subject) as
            # we do here:
            subject { payload }
            it { is_expected.to include(:id) }
            # The subject exists to support this one-line syntax.
            # it's only helpful to use an implicit subject when the context is likely to be well
            # understood by all readers and there is really no need for an example description.
            # Legitimate uses of an explicit anonymous subject or a named subject are very rare.
          end

          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end

        context "when post is a draft" do
          before { get "/posts/#{other_user_post_draft.id}", headers: auth_headers }

          context "payload" do
            subject { payload }
            it { is_expected.to include(:error) }
          end

          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:not_found) } # 404
          end
        end
      end

      context "when requesting user's posts" do
      end
    end
  end

  describe "POST /posts" do
    context "with valid auth" do
      context "should create a post" do
        before { post "/posts", params: create_params, headers: auth_headers }

        # Notice that when I run these two tests, a different user was created for each one
        context "payload" do
          subject { payload }
          it { is_expected.to include(:id, :title, :content, :published, :author) }
        end

        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:created) }
        end
      end

      context "should return an error message on invalid post" do
        before { post "/posts", params: invalid_create_params, headers: auth_headers }

        context "payload" do
          subject { payload }
          it { is_expected.to include(:error) }
        end

        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:unprocessable_entity) }
        end
      end
    end

    context "without auth" do
      before { post "/posts", params: create_params }

      context "payload" do
        subject { payload }
        it { is_expected.to include(:error) }
      end

      context "response" do
        subject { response }
        it { is_expected.to have_http_status(:unauthorized) }
      end
    end
  end

  describe "PUT /posts/{id}" do
    context "with valid auth" do
      context "when updating a user's post" do
        context "should edit a post" do
          before { put "/posts/#{user_post.id}", params: update_params, headers: auth_headers }

          context "payload" do
            subject { payload }
            it { is_expected.to include(:id, :title, :content, :published, :author) }
            it { expect(payload[:id]).to eq(user_post.id) }
          end

          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:ok) }
          end
        end

        context "should return an error message on invalid post" do
          before { put "/posts/#{user_post.id}", params: invalid_update_params, headers: auth_headers }

          context "payload" do
            subject { payload }
            it { is_expected.to include(:error) }
          end

          context "response" do
            subject { response }
            it { is_expected.to have_http_status(:unprocessable_entity) }
          end
        end
      end

      context "when updating other user's post" do
        before { put "/posts/#{other_user_post.id}", params: update_params, headers: auth_headers }

        context "payload" do
          subject { payload }
          it { is_expected.to include(:error) }
        end

        context "response" do
          subject { response }
          it { is_expected.to have_http_status(:not_found) }
        end
      end
    end
  end

  private

  def payload
    # Thanks to the method below, we can use both symbols and strings as keys to access the Hash values.
    # For instance, a hash where keys :foo and "foo" are considered to be the same.
    JSON.parse(response.body).with_indifferent_access
  end
end
