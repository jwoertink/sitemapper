module Sitemapper
  class Builder
    XMLNS_SCHEMA       = "http://www.sitemaps.org/schemas/sitemap/0.9"
    XMLNS_VIDEO_SCHEMA = "http://www.google.com/schemas/sitemap-video/1.1"
    XMLNS_IMAGE_SCHEMA = "http://www.google.com/schemas/sitemap-image/1.1"
    # See: https://sitemaps.org/protocol.html#validating
    XMLNS_XSI                 = "http://www.w3.org/2001/XMLSchema-instance"
    XSI_SCHEMA_LOCATION       = "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"
    XSI_INDEX_SCHEMA_LOCATION = "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"
    DEFAULT_SITEMAP_FILENAME  = "sitemap"
    DEFAULT_INDEX_FILENAME    = "sitemap_index"

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
      build_index(@sitemaps.map { |sm| sm["name"] })
    end

    private def build_index(filenames : Array(String)) : Hash(String, String)
      doc = XML.build(indent: " ", version: "1.0", encoding: "UTF-8") do |xml|
        xml.element("sitemapindex", xmlns: XMLNS_SCHEMA, "xmlns:video": XMLNS_VIDEO_SCHEMA, "xmlns:image": XMLNS_IMAGE_SCHEMA, "xmlns:xsi": XMLNS_XSI, "xsi:schemaLocation": XSI_INDEX_SCHEMA_LOCATION) do
          filenames.each do |name|
            xml.element("sitemap") do
              sitemap_url = [host_for_sitemap, Sitemapper.stored_file_name(name)].join('/')

              xml.element("loc") { xml.text sitemap_url }
              xml.element("lastmod") { xml.text Time.utc.to_s("%FT%X%:z") }
            end
          end
        end
      end
      {"name" => index_file_name, "data" => doc}
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
        sitemap_file_name
      else
        sitemap_file_name(page + 1)
      end
    end

    private def sitemap_file_name(number : Int32? = nil) : String
      "#{Sitemapper.config.sitemap_file_name}#{number}.xml"
    end

    private def index_file_name : String
      "#{Sitemapper.config.index_file_name}.xml"
    end
  end
end
