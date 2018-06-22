module Sitemapper
  class Config
    property use_index : Bool
    property host : String
    property max_urls : Int32
    property storage : Symbol
    property compress : Bool

    def initialize
      @use_index = false
      @host = "http://example.com"
      @max_urls = 500
      @storage = :local
      @compress = true
    end
  end
end
