module Sitemapper
  abstract class Storage
    alias Sitemaps = Array(Hash(String, String))
    getter sitemaps

    def self.init(sitemaps : Sitemaps, method : Symbol)
      case method
      when :local
        LocalStorage.new(sitemaps)
      when :aws
        AwsStorage.new(sitemaps)
      else
        LocalStorage.new(sitemaps)
      end
    end

    def initialize(@sitemaps : Sitemaps)
    end

    abstract def save(path : String) : Void
  end
end
