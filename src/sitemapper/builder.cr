module Sitemapper
  class Builder
    alias Options = NamedTuple(changefreq: String, priority: Float64, lastmod: String, video: VideoMap?, image: ImageMap?)
    
    DEFAULT_OPTIONS = {changefreq: "daily", priority: 0.5, lastmod: Time.now.to_s("%FT%X%:z"), video: nil, image: nil}
    
    def initialize(@host : String = Sitemapper.config.host, @limit : Int32 = Sitemapper.config.max_urls)
      @paginator = Paginator.new(limit: @limit)
    end

    def add(path : String)
      add(path, DEFAULT_OPTIONS.as(Options))
    end

    def add(path : String, options : Options)
      @paginator.add(path, DEFAULT_OPTIONS.merge(options))
    end

    def add(path : String, video : VideoMap, options : Options = DEFAULT_OPTIONS)
      add(path, options.merge(video: video))
    end

    def generate
      @paginator.total_pages.times do |page|
        string = XML.build(indent: " ", version: "1.0", encoding: "UTF-8") do |xml|
          xml.element("urlset", xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
            @paginator.items(page + 1).each do |info|
              path = info[0].as(String)
              options = info[1].as(Options)

              xml.element("url") do
                xml.element("loc") { xml.text [@host, path].join }
                xml.element("lastmod") { xml.text options[:lastmod] }
                xml.element("changefreq") { xml.text options[:changefreq] }
                xml.element("priority") { xml.text options[:priority].to_s }
                if options[:video]?
                  options[:video].as(VideoMap).render_xml(xml)
                end
              end
            end
          end
        end

        string
      end
    end
  end
end
