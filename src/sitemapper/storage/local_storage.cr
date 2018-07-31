require "gzip"

module Sitemapper
  class LocalStorage < Storage
    def save(path : String)
      Dir.mkdir_p(path)
      if Sitemapper.config.compress
        sitemaps.each do |sitemap|
          write_compressed_sitemap(path, sitemap)
        end
      else
        sitemaps.each do |sitemap|
          write_sitemap(path, sitemap)
        end
      end
    end

    private def write_sitemap(path, sitemap)
      File.open([path, sitemap["name"]].join('/'), "w") do |f|
        f << sitemap["data"]
      end
    end

    private def write_compressed_sitemap(path, sitemap)
      File.open([path, sitemap["name"].to_s + ".gz"].join('/'), "w") do |f|
        Gzip::Writer.open(f) do |gzip|
          gzip << sitemap["data"]
        end
      end
    end
  end
end
