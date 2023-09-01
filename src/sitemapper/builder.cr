module Sitemapper
  class Builder
    XMLNS_SCHEMA       = "http://www.sitemaps.org/schemas/sitemap/0.9"
    XMLNS_VIDEO_SCHEMA = "http://www.google.com/schemas/sitemap-video/1.1"
    XMLNS_IMAGE_SCHEMA = "http://www.google.com/schemas/sitemap-image/1.1"
    # See: https://sitemaps.org/protocol.html#validating
    XMLNS_XSI                 = "http://www.w3.org/2001/XMLSchema-instance"
    XSI_SCHEMA_LOCATION       = "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    XSI_INDEX_SCHEMA_LOCATION = "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"

    getter paginator : Paginator

    def initialize(@host : String, @max_urls : Int32, @use_index : Bool)
      @paginator = Paginator.new(limit: @max_urls)
      @sitemaps = [] of Hash(String, String)
    end

    def add(path, **kwargs) : self
      options = SitemapOptions.new(**kwargs)
      paginator.add(path, options)
      self
    end

    def generate : Array(Hash(String, String))
      paginator.total_pages.times do |page|
        filename = filename_for_page(page)
        doc = build_xml_for_page(paginator.items(page + 1))

        @sitemaps << {"name" => filename, "data" => doc}
      end

      if @use_index
        @sitemaps << generate_index
      end

      @sitemaps
    end

    def generate_index : Hash(String, String)
      doc = XML.build(indent: " ", version: "1.0", encoding: "UTF-8") do |xml|
        xml.element("sitemapindex", xmlns: XMLNS_SCHEMA, "xmlns:video": XMLNS_VIDEO_SCHEMA, "xmlns:image": XMLNS_IMAGE_SCHEMA, "xmlns:xsi": XMLNS_XSI, "xsi:schemaLocation": XSI_INDEX_SCHEMA_LOCATION) do
          @sitemaps.each do |sm|
            xml.element("sitemap") do
              sitemap_name = sm["name"].to_s + (Sitemapper.config.compress ? ".gz" : "")
              sitemap_url = [host_for_sitemap, sitemap_name].join('/')

              xml.element("loc") { xml.text sitemap_url }
              xml.element("lastmod") { xml.text Time.utc.to_s("%FT%X%:z") }
            end
          end
        end
      end
      filename = "sitemap_index.xml"
      {"name" => filename, "data" => doc}
    end

    private def host_for_sitemap : String
      (Sitemapper.config.sitemap_host || @host).chomp('/')
    end

    private def build_xml_for_page(items)
      XML.build(indent: " ", version: "1.0", encoding: "UTF-8") do |xml|
        xml.element("urlset", xmlns: XMLNS_SCHEMA, "xmlns:video": XMLNS_VIDEO_SCHEMA, "xmlns:image": XMLNS_IMAGE_SCHEMA, "xmlns:xsi": XMLNS_XSI, "xsi:schemaLocation": XSI_SCHEMA_LOCATION) do
          items.each do |info|
            build_xml_from_info(xml, info)
          end
        end
      end
    end

    private def build_xml_from_info(xml, info)
      path = info[0].as(String)
      options = info[1].as(SitemapOptions)

      xml.element("url") do
        xml.element("loc") { xml.text [@host, path].join }
        xml.element("lastmod") { xml.text options.lastmod.as(Time).to_s("%FT%X%:z") }
        xml.element("changefreq") { xml.text options.changefreq.to_s }
        xml.element("priority") { xml.text options.priority.to_s }
        unless options.video.nil?
          options.video.as(VideoMap).render_xml(xml)
        end
        unless options.image.nil?
          options.image.as(ImageMap).render_xml(xml)
        end
      end
    end

    private def filename_for_page(page)
      if paginator.total_pages == 1
        "sitemap.xml"
      else
        "sitemap#{page + 1}.xml"
      end
    end
  end
end
