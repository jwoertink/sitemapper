require "./spec_helper"

describe Sitemapper::Builder do

  describe "#add/1 " do
    
    it "adds /tacos to the paths" do
      builder = Sitemapper::Builder.new
      builder.add("/tacos")
      builder.paths.size.should eq 1
      builder.paths[0].should eq({"/tacos", Sitemapper::Builder::DEFAULT_OPTIONS})
    end 
  end

  describe "#generate" do
    it "generates the xml with 1 url tag" do
      builder = Sitemapper::Builder.new
      builder.add("/tacos")
      xml = builder.generate
      xml.should contain <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      XML
    
      xml.should contain <<-XML
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      XML

      xml.should contain <<-XML
      <loc>http://example.com/tacos</loc>
      XML
    end
  end
end
