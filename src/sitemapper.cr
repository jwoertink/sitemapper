require "xml"
require "./sitemapper/*"

# TODO: Write documentation for `Sitemapper`
module Sitemapper
  @@configuration = Config.new

  def self.configure
    yield(@@configuration)
    @@configuration
  end

  def self.config
    @@configuration
  end

  def self.build
    builder = Sitemapper::Builder.new
    with builder yield
    builder.generate
  end

end
