require "xml"
require "habitat"

require "./sitemapper/errors"
require "./sitemapper/video_map"
require "./sitemapper/image_map"
require "./sitemapper/sitemap_options"
require "./sitemapper/paginator"
require "./sitemapper/builder"
require "./sitemapper/storage"
require "./sitemapper/streamer"
require "./sitemapper/storage/*"
require "./sitemapper/ping_bot"

module Sitemapper
  VERSION = {{ `shards version #{__DIR__}`.chomp.stringify }}

  Habitat.create do
    setting use_index : Bool = false
    setting host : String, example: "https://mysite.com"
    setting sitemap_host : String? = nil
    setting sitemap_file_name : String = Sitemapper::Builder::DEFAULT_SITEMAP_FILENAME
    setting index_file_name : String = Sitemapper::Builder::DEFAULT_INDEX_FILENAME
    setting max_urls : Int32 = 500
    setting storage : Sitemapper::Storage.class = Sitemapper::LocalStorage
    setting compress : Bool = true
    setting storage_path : String = "tmp/sitemaps"
    setting aws_config : AwsStorageConfig? = nil
  end

  def self.config
    Sitemapper.settings
  end

  # The name a sitemap is actually stored under, which picks up the
  # `.gz` extension when `config.compress` is set.
  def self.stored_file_name(file_name : String) : String
    config.compress ? "#{file_name}.gz" : file_name
  end

  # Build your sitemaps. The block arg is an instance of `Sitemapper::Builder`.
  # Args default to the configuration, but can be overriden.
  # ```
  # Sitemapper.build(max_urls: 20) do |builder|
  #   builder.add("/").add("/about")
  # end
  # ```
  def self.build(
    host : String = config.host,
    max_urls : Int32 = config.max_urls,
    use_index : Bool = config.use_index,
    &
  ) : Array(Hash(String, String))
    builder = Sitemapper::Builder.new(host, max_urls, use_index)
    yield builder
    builder.generate
  end

  # Build your sitemaps, streaming each file. The block arg is an instance of `Sitemapper::Streamer`.
  # Each sitemap is saved to your configured storage as it fills up, then the
  # `sitemap_index.xml` is saved last. Returns the filenames that were saved.
  # Args default to the configuration, but can be overriden.
  # ```
  # Sitemapper.stream(path: "tmp/sitemaps") do |builder|
  #   builder.add("/").add("/about")
  # end
  # ```
  def self.stream(
    host : String = config.host,
    max_urls : Int32 = config.max_urls,
    use_index : Bool = config.use_index,
    storage : Sitemapper::Storage.class = config.storage,
    storage_path : String = config.storage_path,
    &
  ) : Array(String)
    builder = Sitemapper::Streamer.new(host, max_urls, use_index, storage, storage_path)
    yield builder
    builder.finish
  end

  # Store your sitemap xml files.
  # Set the `storage` config option to the class
  # of the storage.
  def self.store(sitemaps : Array(Hash(String, String)), path : String) : Nil
    storage = config.storage.new(sitemaps)
    storage.save(path)
  end

  # Ping Google and Bing, along with any additional engines you want.
  # Pass in the named arg of each additional search engine. Use the `%s` placeholder
  # for replacing the sitemap path.
  # ```
  # Sitemapper.ping_search_engines("https://mysite.com/sitemap.xml", fake_search: "https://fake.search/ping?sitemap=%s")
  # ```
  def self.ping_search_engines(sitemap_url : String, **additional_engines) : Nil
    bot = Sitemapper::PingBot.new(sitemap_url)
    bot.ping(**additional_engines)
  end
end
