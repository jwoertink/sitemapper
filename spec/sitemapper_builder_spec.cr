require "./spec_helper"

describe Sitemapper::Builder do

  describe "#add" do
    
    it "adds /tacos to the paths" do
      builder = Sitemapper::Builder.new(host: "", max_urls: 20, use_index: true)
      builder.add("/tacos")
      builder.paginator.paths.size.should eq 1
    end 
  end

  describe "#generate" do
    it "returns an array with 1 hash" do
      builder = Sitemapper::Builder.new(host: "", max_urls: 20, use_index: true)
      builder.add("/tacos")
      xml = builder.generate
      xml.size.should eq 1
      xml[0].has_key?("name").should eq true
      xml[0]["name"].should eq "sitemap.xml"
    end

    it "returns an array with 4 hashes" do
      builder = Sitemapper::Builder.new(host: "", max_urls: 1, use_index: true)
      builder.add("/tacos/1")
      builder.add("/tacos/2")
      builder.add("/tacos/3")
      builder.add("/tacos/4")
      xml = builder.generate
      xml.size.should eq 4
    end

    it "generates some valid sitemap xml" do
      builder = Sitemapper::Builder.new(host: "http://food.com", max_urls: 100, use_index: true)
      builder.add("/tacos")
      xml = builder.generate.as(Array).first["data"]
      xml.should contain <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      XML
    
      xml.should contain <<-XML
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      XML

      xml.should contain <<-XML
      <loc>http://food.com/tacos</loc>
      XML
    end

    it "generates the xml with a video tag data" do
      builder = Sitemapper::Builder.new(host: "http://food.com", max_urls: 100, use_index: true)
      video = Sitemapper::VideoMap.new(thumbnail_loc: "http://video.org/sample.mpg", title: "Video", description: "This is a video")
      builder.add("/tacos", video: video)
      xml = builder.generate.as(Array).first["data"]
      xml.should contain <<-XML
      <video:video>
      XML

      xml.should contain <<-XML
      <video:thumbnail_loc>http://video.org/sample.mpg</video:thumbnail_loc>
      XML

      xml.should contain <<-XML
      <video:family_friendly>yes</video:family_friendly>
      XML
    end

    it "generates the xml with image tag data" do
      builder = Sitemapper::Builder.new(host: "http://food.com", max_urls: 100, use_index: true)
      image = Sitemapper::ImageMap.new(loc: "http://image.org/sample.jpg", caption: "This is an image")
      builder.add("/tacos", image: image)
      xml = builder.generate.as(Array).first["data"]
      xml.should contain <<-XML
      <image:image>
      XML

      xml.should contain <<-XML
      <image:loc>http://image.org/sample.jpg</image:loc>
      XML

      xml.should contain <<-XML
      <image:caption>This is an image</image:caption>
      XML
    end

  end
end
