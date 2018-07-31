module Sitemapper
  class ConfigurationError < Exception; end

  class Config
    property use_index : Bool
    property host : String
    property max_urls : Int32
    property storage : Symbol
    property compress : Bool
    property aws_config : Hash(String, String) | Nil

    def initialize
      @use_index = false
      @host = "http://example.com"
      @max_urls = 500
      @storage = :local
      @compress = true

      # When set, must contain "region", "key", and "secret" keys with string values
      @aws_config = nil
    end
  end
end
