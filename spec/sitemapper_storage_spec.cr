require "file_utils"
require "./spec_helper"

def with_tempfile
  yield
  if Dir.exists?("./tmp")
    FileUtils.rm_rf("./tmp")
  end
end

describe Sitemapper::Storage do

  describe "with local storage" do
    describe "with compress" do
      it "writes sitemap.xml.gz" do
        with_tempfile do
          storage = Sitemapper::Storage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}], :local)
          storage.save("./tmp")
          File.exists?("./tmp/sitemap.xml.gz").should eq true
          File.size("./tmp/sitemap.xml.gz").should be > 1
        end
      end
    end

    describe "without compress" do
      it "writes sitemap.xml" do
        Sitemapper.configure {|c| c.compress = false}
        with_tempfile do
          storage = Sitemapper::Storage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}], :local)
          storage.save("./tmp")
          File.exists?("./tmp/sitemap.xml").should eq true
          File.size("./tmp/sitemap.xml").should be > 1
        end
      end
    end
  end
end
