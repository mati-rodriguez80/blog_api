class PostReportMailer < ApplicationMailer
  # This method can be named as we wish. In order to generate the email, we need a view that need to
  # have the same name as the method we implement here, inside a folder named the same as the current
  # file we're working on.
  def post_report(user, post, post_report)
    @post = post
    @post_report = post_report
    # ActionMailer has its own DSL which allows us to write code like this one.
    mail to: user.email, subject: "Post #{post.id} report"
  end
end
