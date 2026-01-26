require "../builder"

module Sitemapper
  # This class builds a list of sitemaps in memory, but doesn't save them. The
  # caller must eventually call `Sitemapper.store` to save the resulting list
  # of sitemaps.
  class InMemoryBuilder < Builder
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

    def index_add(path) : self
      paginator.index_add(path)
      self
    end

    def generate : Array(Hash(String, String))
      paginator.total_pages.times do |page|
        filename = filename_for_page(page)
        doc = build_xml_for_page(paginator.items(page + 1))

        @sitemaps << {"name" => filename, "data" => doc}
      end

      if @use_index
        filenames = paginator.index_items
        filenames += @sitemaps.map { |sitemap| sitemap["name"] }
        @sitemaps << generate_index(filenames)
      end

      @sitemaps
    end

    private def filename_for_page(page)
      if paginator.total_pages == 1
        Sitemapper.config.sitemap_file_name + ".xml"
      else
        Sitemapper.config.sitemap_file_name + "#{page + 1}.xml"
      end
    end
  end
end
