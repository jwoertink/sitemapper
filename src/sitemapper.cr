require "xml"
require "habitat"

require "./sitemapper/errors"
require "./sitemapper/video_map"
require "./sitemapper/image_map"
require "./sitemapper/sitemap_options"
require "./sitemapper/paginator"
require "./sitemapper/builder"
require "./sitemapper/storage"
require "./sitemapper/storage/*"
require "./sitemapper/ping_bot"

module Sitemapper
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  Habitat.create do
    setting use_index : Bool = false
    setting host : String, example: "https://mysite.com"
    setting sitemap_host : String? = nil
    setting max_urls : Int32 = 500
    setting storage : Symbol = :local
    setting compress : Bool = true
    setting aws_config : Hash(String, String)? = nil
  end

  def self.config
    Sitemapper.settings
  end

  def self.build
    builder = Sitemapper::Builder.new(config.host, config.max_urls, config.use_index)
    # The following two lines are duplicated from self.build with a block, since
    # the "with builder yield" is not working when just delegating and passing
    # the block
    with builder yield
    builder.generate
  end

  def self.build(host : String, max_urls : Int32, use_index : Bool)
    builder = Sitemapper::Builder.new(host, max_urls, use_index)
    with builder yield
    builder.generate
  end

  def self.store(sitemaps, path)
    storage = Sitemapper::Storage.init(sitemaps, config.storage.as(Symbol))
    storage.save(path)
  end

  def self.ping_search_engines(sitemap_url, **additional_engines)
    bot = Sitemapper::PingBot.new(sitemap_url)
    bot.ping(**additional_engines)
  end
end
