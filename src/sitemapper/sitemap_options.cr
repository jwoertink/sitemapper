record SitemapOptions,
  changefreq = "daily",
  priority = 0.5,
  lastmod : Time = Time.now,
  video : Sitemapper::VideoMap? = nil,
  image : Sitemapper::ImageMap? = nil
  
