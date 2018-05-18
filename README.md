# sitemapper

Sitemapper helps you to generate sitemaps for your website. It builds [compliant XML](https://www.sitemaps.org/protocol.html) files and allows you to customize which parts of your site are indexed.

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
puts sitemaps.total #=> 4
puts sitemaps.index #=> {"name" => "sitemap.xml", "data" => "..."}
puts sitemaps.all   #=> [{"name" => "sitemap1.xml", "data" => ""},...]

# Just have Sitemapper write them out to your public/sitemaps folder
Sitemapper.store(sitemaps, "public/sitesmaps")
```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/jwoertink/sitemapper/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [jwoertink](https://github.com/jwoertink) Jeremy Woertink - creator, maintainer
