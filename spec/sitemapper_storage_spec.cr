require "file_utils"
require "./spec_helper"

def with_tempdir
  yield("./tmp")
  if Dir.exists?("./tmp")
    FileUtils.rm_rf("./tmp")
  end
end

describe Sitemapper::Storage do
  describe "with local storage" do
    describe "with compress" do
      it "writes sitemap.xml.gz" do
        with_tempdir do |dir|
          storage = Sitemapper::Storage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}], :local)
          storage.save(dir)
          File.exists?("#{dir}/sitemap.xml.gz").should eq true
          File.size("#{dir}/sitemap.xml.gz").should be > 1
        end
      end
    end

    describe "without compress" do
      it "writes sitemap.xml" do
        Sitemapper.configure { |c| c.compress = false }
        with_tempdir do |dir|
          storage = Sitemapper::Storage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}], :local)
          storage.save(dir)
          File.exists?("#{dir}/sitemap.xml").should eq true
          File.size("#{dir}/sitemap.xml").should be > 1
        end
      end
    end
  end
end
