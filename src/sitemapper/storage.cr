module Sitemapper
  abstract class Storage
    alias Sitemaps = Array(Hash(String, String))
    getter sitemaps : Sitemaps

    def initialize(@sitemaps : Sitemaps)
    end

    abstract def save(path : String) : Nil
  end
end
