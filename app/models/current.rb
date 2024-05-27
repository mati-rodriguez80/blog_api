class Current < ActiveSupport::CurrentAttributes
  # Current Attribues: Abstract super class that provides a thread-isolated attributes singleton,
  # which resets automatically before and after each request. This allows you to keep all the
  # per-request attributes easily available to the whole system. We use Current class to facilitate
  # easy access to the global, per-request attributes without passing them deeply around everywhere.

  # A word of caution: It’s easy to overdo a global singleton like Current and tangle your model as
  # a result. Current should only be used for a few, top-level globals, like account, user, and
  # request details. The attributes stuck in Current should be used by more or less all actions on
  # all requests. If you start sticking controller-specific attributes in there, you’re going to
  # create a mess.

  # By convention, this Current class is being implemented in our models folder. And in this
  # class, we're going to store the model that we want it to be accessible for the current
  # session.
  # Then, we just define the attributes that we want to be accessible.
  attribute :user
end
