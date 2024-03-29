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
Sitemapper.configure do |c|
  # Generate a sitemap_index file
  c.use_index = true # default false

  c.host = "https://yoursite.io"

  c.sitemap_host = "https://sitemaps.aws.whatever.com" # default nil

  # The max number of <url> elements to add to each sitemap
  c.max_urls = 20 # default 500

  # use gzip compression?
  c.compress = false # default true

  # which storage class to use
  c.storage = Sitemapper::AwsStorage  # default is SiteMapper::LocalStorage

  # see the aws config docs below
  c.aws_config = AwsStorageConfig.new(...) # default is nil but should be an AwsStorageConfig when used
end

# Use sitemapper
sitemaps = Sitemapper.build do |builder|
  builder.add("/about", changefreq: "yearly", priority: 0.1)
  builder.add("/profiles/somedude", changefreq: "always", priority: 0.9)
end

# Do whatever you want with these.
# Maybe upload to S3, or write to a file
puts typeof(sitemaps) #=> Array(Hash(String, String))
puts sitemaps.first #=> {"name" => "sitemap1.xml", "data" => "<?xml ..."}

# Just have Sitemapper write them out to your public/sitemaps folder
# This will create ./public/sitemaps/sitemap1.xml, etc...
Sitemapper.store(sitemaps, "./public/sitesmaps")
```

You can also pass options to `build`.

```crystal
Sitemapper.build(host: "your host", max_urls: 20, use_index: true) do |builder|
  builder.add("/whatever", lastmod: Time.utc)
end
```

## Adding videos to your sitemap

You can add in video information which will generate the necessary XML for videos. Check out [the docs](https://developers.google.com/webmasters/videosearch/sitemaps) for all the different options you can use.

Sitemapper uses a `Sitemapper::VideoMap` object for building out video sitemap data. Pretty much the attributes all map 1 to 1 except for `tag`. Use the plural `tags` as an array.

```crystal
video = Sitemapper::VideoMap.new(thumbnail_loc: "http://video.org/sample.mpg", title: "Video", description: "This is a video", tags: ["one", "two"])
sitemaps = Sitemapper.build do |builder|
  builder.add("/videos/123", video: video, changefreq: "yearly")
end
```

Same goes for in you want to add an image. Use `Sitemapper::ImageMap` and pass `add("/image/1", image: image)`. Read up more on [image sitemaps here](https://support.google.com/webmasters/answer/178636?hl=en).

## Saving your XML

Sitemapper gives you the raw XML in strings. This gives you the option to save that data however you wish. Maybe you're crazy and want to store it in your DB? Maybe you're running on Heroku and can't just write locally, so you need to ship it off to AWS. What ever the case, you have that freedom.

There's a few options you have built in. `LocalStorage`, and `AwsStorage`. These are config options through `config.storage`

### LocalStorage

By default Sitemapper will use local storage which is just writing your XML to some flat files and stored somewhere relative to your application.

```crystal
Sitemapper.configure do |c|
  # no need to configure anything extra
end

# `sitemaps` is the Array(Hash(String, String)) from above
# writes to ./public/sitemaps/sitemap.xml
Sitemapper.store(sitemaps, "public/sitemaps")
```

If you would like to store these sitemaps in gzip files, you'll need to set the `compress` option.

```crystal
Sitemapper.configure do |c|
  c.compress = true
end

# writes to ./public/sitemaps/sitemap.xml.gz
Sitemapper.store(sitemaps, "public/sitemaps")
```

### AwsStorage

If you're hosted somewhere like Heroku or Elasticbeanstalk then you may not have the ability to just write your flat files locally. In this case, you can use the `AwsStorage` option to push the files to S3 (or an S3 compatible location).

You'll probably also want to set the `sitemap_host` option here. This is so the `sitemap_index.xml` will know where all the other sitemap files will be located.

```crystal
Sitemapper.configure do |c|
  c.storage = Sitemapper::AwsStorage

  # This option is important!
  c.aws_config = AwsStorageConfig.new(
    region: ENV["AWS_REGION"],
    key: ENV["AWS_ACCESS_KEY"],
    secret: ENV["AWS_SECRET_KEY"],
    # Set this option only if you need an alternative host from S3, or the S3 host has changed
    endpoint: "https://digitalocean.com/whatever"
  )

  c.sitemap_host = "https://my-prod-bucket.s3.amazonaws.com"
end

# uploads to your bucket my-prod-bucket/sitemaps/sitemap.xml
Sitemapper.store(sitemaps, "my-prod-bucket/sitemaps")
```

Lastly, so the searchengines know where your sitemaps are located (unless you aliased `/sitemap_index.xml`), you'll want to update your [robots.txt](http://www.robotstxt.org/) with `Sitemap: https://my-sitemap-host.com`

## Notifying Search Engines

Once you have your sitemaps updated, it's usually a good idea to let the search engines know. Generally, they will crawl your site regularly anyway, but this at least gets things moving a little quicker. To do this, you can use the `ping_search_engines` method.

```crystal
sitemap_url = whatever_you_put_in_your_robots_txt
Sitemapper.ping_search_engines(sitemap_url)
```

Currently, this only pings Google and Bing. However, if you wanted to ping another engine like a custom one, or maybe Yandex, you can pass that in as well.

```crystal
# be sure to include %s so we know where to place your `sitemap_url`
Sitemapper.ping_search_engines(sitemap_url, yandex: "http://blogs.yandex.ru/pings/?status=success&url=%s")
```

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
- [hanneskaeufler](https://github.com/hanneskaeufler) Hannes Käufler - updates
