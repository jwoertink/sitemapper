record SitemapOptions,
  changefreq = "daily",
  priority = 0.5,
  lastmod : String = Time.now.to_s("%FT%X%:z"),
  video : Sitemapper::VideoMap? = nil,
  image : Sitemapper::ImageMap? = nil
  
