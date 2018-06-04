module Sitemapper
  class Storage
    getter sitemaps

    def initialize(@sitemaps : Array(Hash(String, String)), @method : Symbol)
    end

    def save(path : String)
      Dir.mkdir_p(path)
      sitemaps.each do |sitemap|
        File.open([path, sitemap["name"]].join('/'), "w") do |f|
          f << sitemap["data"]
        end
      end
    end

  end
end
