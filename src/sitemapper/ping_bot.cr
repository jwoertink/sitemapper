require "uri"
require "http/client"

module Sitemapper
  class PingBot
    # The URL to your sitemap_index file
    def initialize(@sitemap_index : String)
    end

    @[Deprecated("The `ping` no longer works. See each search engine for their proper methods of submitting sitemaps")]
    def ping(**other_engines) : Nil
      # Remove after v0.11
    end
  end
end
