require "xml"
require "./sitemapper/*"

# TODO: Write documentation for `Sitemapper`
module Sitemapper
  @@configuration = Config.new

  def self.configure
    yield(@@configuration)
    @@configuration
  end

  def self.config
    @@configuration
  end

  def self.build
    build(host: config.host, mex_urls: config.max_urls, use_index: config.use_index)
  end

  def self.build(host : String, max_urls : Int32, use_index : Bool)
    builder = Sitemapper::Builder.new(host, max_urls, use_index)
    with builder yield
    builder.generate
  end

  def self.store(sitemaps, path)
    Dir.mkdir_p(path)
    sitemaps.each do |sitemap|
      File.open([path, sitemap["name"]].join('/'), "w") do |f|
        f << sitemap["data"]
      end
    end
  end

end
