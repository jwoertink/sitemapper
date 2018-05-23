# sitemapper

Sitemapper helps you to generate sitemaps for your website. It generates [sitemap compliant XML](https://www.sitemaps.org/protocol.html), and gives you the flexibility to handle what is generated, and where you place your sitemaps.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  sitemapper:
    github: jwoertink/sitemapper
```

## Usage

```crystal
require "sitemapper"

# Configure sitemapper
Sitemapper.config do |c|
  # Generate a sitemap_index file
  c.use_index = true # default false

  c.host = "https://yoursite.io"

  # The max number of <url> elements to add to each sitemap
  c.max_urls = 20 # default 500 
end

# Use sitemapper
sitemaps = Sitemapper.build do
  add("/about", changefreq: "yearly", priority: 0.1)
  add("/profiles/somedude", changefreq: "always", priority: 0.9)
end

# Do whatever you want with these. 
# Maybe upload to S3, or write to a file
puts typeof(sitemaps) #=> Array(Hash(String, String))
puts sitemaps.size  #=> 4
puts sitemaps.first #=> {"name" => "sitemap1.xml", "data" => "<?xml ..."}

# Just have Sitemapper write them out to your public/sitemaps folder
Sitemapper.store(sitemaps, "public/sitesmaps")
```

You can also pass options to `build`.

```crystal
Sitemapper.build(host: "your host", max_urls: 20, use_index: true) do

end
```

## Adding videos to your sitemap

You can add in video information which will generate the necessary XML for videos. Check out [the docs](https://developers.google.com/webmasters/videosearch/sitemaps) for all the different options you can use. 

Sitemapper uses a `Sitemapper::VideoMap` object for building out video sitemap data.

```crystal
video = Sitemapper::VideoMap.new(thumbnail_loc: "http://video.org/sample.mpg", title: "Video", description: "This is a video")
sitemaps = Sitemapper.build do
  add("/videos/123", video: video, changefreq: "yearly")
end
```

Same goes for in you want to add an image. Use `Sitemapper::ImageMap` and pass `add("/image/1", image: image)`. Read up more on [image sitemaps here](https://support.google.com/webmasters/answer/178636?hl=en).

## Development

Nothing fancy. Just pull down the repo, add code and make sure specs are passing.

## Contributing

1. Fork it ( https://github.com/jwoertink/sitemapper/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Add some specs and run `crystal spec/`
4. Commit your changes (git commit -am 'Add some feature')
5. Push to the branch (git push origin my-new-feature)
6. Create a new Pull Request

## Contributors

- [jwoertink](https://github.com/jwoertink) Jeremy Woertink - creator, maintainer
