class PostReportJob < ApplicationJob
  # This is important when we're using an external implementation like Redis, Sidekiq, etc. which we can use
  # in Rails, where they utilize queues. Then, we can specify different queues and priorities for each of them.
  # In this simple API we're going to use the default which uses a threadpool.
  queue_as :default

  # To generate the report, we're going to need a user and a post. It's recommended trying to pass light data
  # like ids because, depending on the implementation, we may have problems if we pass in complex data structures
  # such as a whole model.
  def perform(user_id, post_id)
    user = User.find(user_id)
    post = Post.find(post_id)
    report = PostReport.generate(post)
    # User request a post report, then the app emails the report.
    # Here we have two alternatives: deliver_now or deliver_later. When we use deliver later, Rails, by default,
    # automatically will use ActiveJob to send this email in the background. However, since in this case we're
    # already in a background job, this is not necessary. So, we can just send it inmediately with deliver_now.
    PostReportMailer.post_report(user, post, report).deliver_now
  end

  # We finally test this job in Rails console. We run PostReportJob.perform_later(User.first.id, Post.first.id).
end
