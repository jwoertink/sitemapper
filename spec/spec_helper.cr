require "spec"
require "webmock"
require "../src/sitemapper"

Sitemapper.configure do |settings|
  settings.host = "http://example.com"
end
