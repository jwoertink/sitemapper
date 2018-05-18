module Sitemapper
  class Builder
    alias Options = NamedTuple(changefreq: String, priority: Float64, lastmod: String)
    
    DEFAULT_OPTIONS = {changefreq: "daily", priority: 0.5, lastmod: Time.now.to_s("%FT%X%:z")}
    property paths : Array(Tuple(String, Options))
    
    def initialize
      @paths = [] of Tuple(String, Options)
    end

    def add(path : String)
      add(path, DEFAULT_OPTIONS.as(Options))
    end

    def add(path : String, options : Options)
      @paths << {path, DEFAULT_OPTIONS.merge(options)}
    end

    def generate
      string = XML.build(indent: " ", version: "1.0", encoding: "UTF-8") do |xml|
        xml.element("urlset", xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
          @paths.each do |info|
            xml.element("url") do
              xml.element("loc") { xml.text [Sitemapper.config.host, info[0].as(String)].join }
              xml.element("lastmod") { xml.text info[1].as(Options)[:lastmod] }
              xml.element("changefreq") { xml.text info[1].as(Options)[:changefreq] }
              xml.element("priority") { xml.text info[1].as(Options)[:priority].to_s }
            end
          end
        end
      end

      string
    end
  end
end
