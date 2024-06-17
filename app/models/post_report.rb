class PostReport < Struct.new(:word_count, :word_histogram)
  # Struct in Ruby is a great tool for simple classes that mainly store data. It's a quick and efficient way
  # to create such classes without the overhead of writing a full class definition. Use it when you need a
  # straightforward way to encapsulate data with minimal functionality.

  # We'll use this class as representation of our report. It's recommended to create classes to represent
  # the different types of data that we have in our app.
  # This report is going to have a word_count of the content of the post, and a word_histogram (a repetition
  # counter).

  def self.generate(post)
    # Here we create a new PostReport
    PostReport.new(
      # word_count
      # In Ruby, gsub (global substitution) is a method used to search and replace patterns in a string.
      # It returns a new string where all occurrences of the pattern are replaced by the specified replacement.
      # \W: This is a regular expression pattern that matches any non-word character (anything that is not a
      # letter, digit, or underscore).
      post.content.split.map { |word| word.gsub(/\W/, '') }.count,
      # word_histogram
      calc_histogram(post)
    )
  end

  private

  # calc_histogram is used within the generate class method, which suggests that it's not dependent on the
  # state of an instance but rather performs a calculation based on the input post. It operates at the class
  # level, not needing to access or modify instance-specific data.
  # calc_histogram(post) is called as self.calc_histogram(post) implicitly within the generate class method.
  # Since generate is a class method, it cannot call instance methods directly on the class.
  def self.calc_histogram(post)
    (post
      .content
      .split
      .map { |word| word.gsub(/\W/, '') }
      .map(&:downcase)
      # The group_by method in Ruby takes a block and groups elements of an array into a hash based on the
      # value returned by the block. Return Value: A hash where the keys are the values returned by the block,
      # and the values are arrays of elements that correspond to each key.
      .group_by { |word| word }
      # The transform_values method is used to create a new hash by transforming the values of the existing
      # hash according to the provided block. The keys remain unchanged.
      .transform_values(&:size)
    )
  end
end
