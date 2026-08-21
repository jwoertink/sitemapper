require "spec"
require "file_utils"
require "../src/sitemapper"

Sitemapper.configure do |settings|
  settings.host = "http://example.com"
end

def with_tempdir(&)
  dir = "./tmp"
  FileUtils.rm_rf(dir) if Dir.exists?(dir)
  Dir.mkdir_p(dir)
  begin
    yield(dir)
  ensure
    FileUtils.rm_rf(dir) if Dir.exists?(dir)
  end
end
