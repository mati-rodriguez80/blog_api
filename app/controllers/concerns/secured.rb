module Secured
  # In Rails, a "concern" has to do with a module where we will have methods that can be reutilized for
  # several controllers. A folder like this can be also found in models folder where the concept is
  # the same.

  def authenticate_user!
    # Bearer xxxxx. When we use "()" in regex, we're defining a group of characters, and we can
    # then extract that group of capture using "[]" like below.
    token_regex = /Bearer (\w+)/
    # Read auth header
    headers = request.headers
    # Verify if it is valid
    if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
      # If we use match[0] we'll get the whole string get by the regex. But the next positions of
      # the MatchData are going to be the different capture groups.
      token = headers['Authorization'].match(token_regex)[1]
      # Verify that the token matchs a user's token
      # Also, we also need to store this user to make it accesible everywhere in the application.
      # For this, we're going to use a new function provided since Rails 5 which is Current Attributes.
      # From stackoverflow: The "find" method is usually used to retrieve a row by ID. The "find_by" is
      # used as a helper when you're searching for information within a column, and it maps to such with
      # naming conventions. Finally, "where" is more of a catch all that lets you use a bit more complex
      # logic for when the conventional helpers won't do, and it returns an array of items that match
      # your conditions (or an empty array otherwise).
      if (Current.user = User.find_by_auth_token(token))
        return
      end
    end

    render json: { error: 'Unauthorized' }, status: :unauthorized # 401
  end
end
