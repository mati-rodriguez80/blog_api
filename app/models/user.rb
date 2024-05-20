class User < ApplicationRecord
  has_many :posts

  validates :email, presence: true
  validates :name, presence: true
  validates :auth_token, presence: true

  # This is a method provided by Rails in the models to execute methods after the object is being
  # initialized. So here, generate_auth_token method is going to be executed inmediately after
  # User.new happens in this case. This means that we are going to have information like email,
  # name, etc. available if they were fulfilled.
  after_initialize :generate_auth_token

  def generate_auth_token
    # Same as if !auth_token.present?
    unless auth_token.present?
      self.auth_token = TokenGenerationService.generate
    end
  end
end
