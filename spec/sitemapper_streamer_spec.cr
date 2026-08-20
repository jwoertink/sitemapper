require "./spec_helper"

private def stream_config(use_index : Bool = true, &)
  Sitemapper.temp_config(
    host: "http://example.com",
    sitemap_host: "https://sitemaps.example.com",
    compress: false,
    use_index: use_index,
    storage: Sitemapper::LocalStorage
  ) do
    with_tempdir do |dir|
      yield dir
    end
  end
end

private def stream_urls(count : Int32, dir : String, max_urls : Int32 = 500)
  Sitemapper.stream(max_urls: max_urls, storage_path: dir) do |builder|
    count.times { |i| builder.add("/posts/#{i}") }
  end
end

private def written_files(dir : String) : Array(String)
  Dir.glob("#{dir}/*.xml").map { |file| File.basename(file) }.sort!
end

private def loc_count(path : String) : Int32
  File.read(path).scan(/<loc>/).size
end

describe Sitemapper::Streamer do
  describe "#finish" do
    it "writes the trailing partial sitemap along with the full ones" do
      stream_config do |dir|
        stream_urls(1050, dir)

        written_files(dir).should eq [
          "sitemap1.xml",
          "sitemap2.xml",
          "sitemap3.xml",
          "sitemap_index.xml",
        ]
        loc_count("#{dir}/sitemap1.xml").should eq 500
        loc_count("#{dir}/sitemap2.xml").should eq 500
        loc_count("#{dir}/sitemap3.xml").should eq 50
      end
    end

    it "writes an index listing every sitemap it saved" do
      stream_config do |dir|
        stream_urls(1050, dir)

        index = File.read("#{dir}/sitemap_index.xml")
        index.scan(/<loc>/).size.should eq 3
        index.should contain "<loc>https://sitemaps.example.com/sitemap1.xml</loc>"
        index.should contain "<loc>https://sitemaps.example.com/sitemap2.xml</loc>"
        index.should contain "<loc>https://sitemaps.example.com/sitemap3.xml</loc>"
      end
    end

    it "does not list the index inside itself" do
      stream_config do |dir|
        stream_urls(1050, dir)

        File.read("#{dir}/sitemap_index.xml").should_not contain "sitemap_index.xml"
      end
    end

    it "writes no empty trailing sitemap when the count divides evenly" do
      stream_config do |dir|
        stream_urls(1000, dir)

        written_files(dir).should eq [
          "sitemap1.xml",
          "sitemap2.xml",
          "sitemap_index.xml",
        ]
        File.read("#{dir}/sitemap_index.xml").scan(/<loc>/).size.should eq 2
      end
    end

    it "writes a single sitemap and an index when under the max" do
      stream_config do |dir|
        stream_urls(10, dir)

        written_files(dir).should eq ["sitemap1.xml", "sitemap_index.xml"]
        loc_count("#{dir}/sitemap1.xml").should eq 10
        File.read("#{dir}/sitemap_index.xml").scan(/<loc>/).size.should eq 1
      end
    end

    it "skips the index when use_index is false" do
      stream_config(use_index: false) do |dir|
        stream_urls(1050, dir)

        written_files(dir).should eq ["sitemap1.xml", "sitemap2.xml", "sitemap3.xml"]
      end
    end

    it "returns every filename it wrote" do
      stream_config do |dir|
        stream_urls(1050, dir).should eq [
          "sitemap1.xml",
          "sitemap2.xml",
          "sitemap3.xml",
          "sitemap_index.xml",
        ]
      end
    end

    it "writes valid sitemap xml" do
      stream_config do |dir|
        stream_urls(10, dir)

        File.read("#{dir}/sitemap1.xml").should contain %(<?xml version="1.0" encoding="UTF-8"?>)
        File.read("#{dir}/sitemap_index.xml").should contain %(<?xml version="1.0" encoding="UTF-8"?>)
        File.read("#{dir}/sitemap1.xml").should contain "<loc>http://example.com/posts/0</loc>"
      end
    end
  end
end
