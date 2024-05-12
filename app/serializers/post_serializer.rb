class PostSerializer < ActiveModel::Serializer
  # As soon we create a serializer, by convention Rails uses this serializer to generate
  # the representation in JSON of the model in which this serializer is associated with.
  attributes :id, :title, :content, :published, :author

  # Since author is not part of post model, we have to define it
  def author
    # With self.object we are pointing at the object being serialized (post). Then, we
    # access the user associated with the post.
    user = self.object.user
    {
      name: user.name,
      email: user.email,
      id: user.id
    }
  end
end
