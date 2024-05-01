require 'rails_helper'

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:posts) }
  end

  describe "validations" do
    it "validates presence of required fields" do
      should validate_presence_of(:email)
      should validate_presence_of(:name)
      should validate_presence_of(:auth_token)
    end
  end
end
