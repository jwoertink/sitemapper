require "../builder"

module Sitemapper
  # This class builds sitemap files one at a time, saving each as it reaches
  # the limit of `@max_urls`. Callers don't need to call `Sitemapper.store`
  # afterwards.
  class StreamBuilder < Builder
    getter paginator : Paginator

    def initialize(@host : String, @max_urls : Int32, @use_index : Bool, @storage : Sitemapper::Storage.class, @storage_path : String)
      @paginator = Paginator.new(limit: @max_urls)
      @filenames = [] of String
      @index_filenames = [] of String
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

    def flush(page)
      filename = filename_for_page(page)
      doc = build_xml_for_page(paginator.items(page))
      @filenames << filename

      storage = @storage.new([{"name" => filename, "data" => doc}])
      storage.save(@storage_path)
    end

    def finish : Void
      paginator.total_pages.times do |page|
        flush(page + 1)
      end

      if @use_index
        save_index
      end
    end

    private def save_index : Void
      @index_filenames += paginator.index_items
      index = generate_index(@index_filenames + @filenames)
      storage = @storage.new([index])
      storage.save(@storage_path)
    end

    private def filename_for_page(page)
      Sitemapper.config.sitemap_file_name + "#{page}.xml"
    end
  end
end
