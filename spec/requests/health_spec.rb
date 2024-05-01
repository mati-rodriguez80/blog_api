require "rails_helper"

# For integration tests we use type: :request. With integration tests we can test a system
# end to end. They are important to test that every component of the application work in harmony.
# They take more time than unit tests since they have to load every component at the same time.
RSpec.describe "Health endpoint", type: :request do
  describe "GET /health" do
    # This should happen before each test
    before { get '/health' }

    it "should return OK" do
      # "response" is available because is type request, and we can access it after a http request
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      # In a health check endpoint, we usually test the different states of the different services
      # that the application has, e.g. api: OK, db: DOWN, etc.
      expect(payload['api']).to eq('OK')
    end

    it "should return status code 200" do
      expect(response).to have_http_status(200)
    end
  end
end
