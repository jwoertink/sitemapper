module Sitemapper
  class Storage
    alias Sitemaps = Array(Hash(String, String))
    getter sitemaps

    def initialize(@sitemaps : Sitemaps)
    end

    def self.init(sitemaps : Sitemaps, method : Symbol)
      case method
      when :local
        LocalStorage.new(sitemaps)
      else
        LocalStorage.new(sitemaps)
      end 
    end

  end
end

require "./storage/*"
