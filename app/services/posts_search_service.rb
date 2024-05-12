class PostsSearchService
  # We could have filtered posts in PostsController. But, it's not a good practice to implement all
  # the logic in the controllers. A good practice is to make controllers as light as possible, and
  # to let them only call other components where the business logic actually lives.
  # So, even though we can place all the logic in our controllers, we've created this additional
  # component, a class, which will be in charge of searching posts.
  # Besides what was explained before, since we are encapsulating our search logic in one class, when
  # we wanted to modify this logic, we'll just modify what we have here. For example, this could be
  # especially useful in an application where we need to make it more scalable because we have a lot
  # of requests, replacing this search with a search that utilizes a service like Elastic Search.
  # Because doing a text search in a database is not scalable since a database is not design to
  # manage text queries.
  def self.search(current_posts, query)
    current_posts.where("title like '%#{query}%'")
  end
end
