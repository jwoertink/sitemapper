module Sitemapper
  class Config
    property use_index : Bool
    property host : String
    property max_urls : UInt32

    def initialize
      @use_index = false
      @host = "http://example.com"
      @max_urls = 500_u32
    end
  end
end
