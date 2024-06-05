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
    # SQL databases are not optimized to make text searches. So, this kind of searches can be very
    # slow in a real production system where we have a lot of articles and text. Therefore, in order
    # to make this request faster, we're going to use caching provided by Rails.
    # Now, we're going to access Rails cache, and use fetch to get what we have in the cache. A cache
    # usually works like a key-value database. So, if we already have a value for a key, we'll just
    # get the value, otherwise the value will be calculated and saved. Additionally, in this case we
    # can pass in an additional parameter which is expires_in to expire the value after certain time.
    # This is important here since we don't want the value to be stored forever because posts can
    # change and new post that match the query may appear.
    # It's worth mentioning that doing this means sacrifice preciseness with performance because we'll
    # return a pre-calculated value which will save for an hour meanwhile new posts can be created
    # that have the query.
    posts_ids = Rails.cache.fetch("posts_search/#{query}", expires_in: 1.hours) do
      # Another thing to take into account is to not store all the posts content in the cache since
      # cache usually has a limited space for storing. So, we have to store the minimum amount of
      # information possible. In this case we'll store only the posts ids, and then we'll do a query
      # to the database to return the posts based on these ids.
      # So, we're replacing a query for another query. However, a text query using "like" can take a
      # lot of time, and the new query will now use the ids. At that point we'll already have the ids,
      # and the ids in the models are usually indexed, therefore the queries will be really fast.
      current_posts.where("title like '%#{query}%'").map(&:id)
    end

    current_posts.where(id: posts_ids)
  end
end
