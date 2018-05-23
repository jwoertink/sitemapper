module Sitemapper
  class Builder
    alias Options = NamedTuple(changefreq: String, priority: Float64, lastmod: String, video: VideoMap?, image: ImageMap?)
    
    DEFAULT_OPTIONS = {changefreq: "daily", priority: 0.5, lastmod: Time.now.to_s("%FT%X%:z"), video: nil, image: nil}

    getter paginator
    
    def initialize(@host : String, @max_urls : Int32, @use_index : Bool)
      @paginator = Paginator.new(limit: @max_urls)
      @sitemaps = [] of Hash(String, String)
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

    def add(path : String, image : ImageMap, options : Options = DEFAULT_OPTIONS)
      add(path, options.merge(image: image))
    end

    def generate
      @paginator.total_pages.times do |page|
        filename = filename_for_page(page)
        doc = XML.build(indent: " ", version: "1.0", encoding: "UTF-8") do |xml|
          xml.element("urlset", xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do
            @paginator.items(page + 1).each do |info|
              build_xml_from_info(xml, info)
            end
          end
        end

        @sitemaps << {"name" => filename, "data" => doc}
      end

      @sitemaps
    end

    private def build_xml_from_info(xml, info)
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
        if options[:image]?
          options[:image].as(ImageMap).render_xml(xml)
        end
      end
    end

    private def filename_for_page(page)
      if @paginator.total_pages == 1
        "sitemap.xml"
      else
        "sitemap#{page + 1}.xml"
      end
    end

  end
end
