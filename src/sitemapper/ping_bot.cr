require "uri"
require "http/client"

module Sitemapper
  class PingBot
    ENGINES = {
      google: "https://www.google.com/webmasters/tools/ping?sitemap=%s",
      bing:   "https://www.bing.com/webmaster/ping.aspx?siteMap=%s",
    }

    # The URL to your sitemap_index file
    def initialize(@sitemap_index : String)
    end

    # You can add other URLs like
    # ping(yandex: "http://blogs.yandex.ru/pings/?status=success&url=%s")
    def ping(**other_engines)
      ENGINES.merge(other_engines).each do |_engine, url|
        sitemap_url = String.build do |str|
          str << (url % URI.encode_www_form(@sitemap_index))
        end

        HTTP::Client.get(sitemap_url)
      end
    end
  end
end
