class TokenGenerationService
  def self.generate
    # We use the hex method because we're interesting in an string.
    SecureRandom.hex
  end
end
