module Sitemapper
  class Error < Exception
  end

  # Raised when there's an issue with the configuration
  class ConfigurationError < Error
  end
end
