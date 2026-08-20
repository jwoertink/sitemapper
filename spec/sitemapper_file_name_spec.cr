require "./spec_helper"

private def built_names(count : Int32, max_urls : Int32, use_index : Bool) : Array(String)
  sitemaps = Sitemapper.build(max_urls: max_urls, use_index: use_index) do |builder|
    count.times { |i| builder.add("/posts/#{i}") }
  end
  sitemaps.map { |sitemap| sitemap["name"] }
end

private def built_index(count : Int32, max_urls : Int32) : String
  sitemaps = Sitemapper.build(max_urls: max_urls, use_index: true) do |builder|
    count.times { |i| builder.add("/posts/#{i}") }
  end
  sitemaps.last["data"]
end

describe "file name configuration" do
  describe "defaults" do
    it "names a lone sitemap sitemap.xml" do
      Sitemapper.temp_config(compress: false) do
        built_names(1, 500, false).should eq ["sitemap.xml"]
      end
    end

    it "numbers sitemaps when there is more than one" do
      Sitemapper.temp_config(compress: false) do
        built_names(3, 1, false).should eq ["sitemap1.xml", "sitemap2.xml", "sitemap3.xml"]
      end
    end

    it "names the index sitemap_index.xml" do
      Sitemapper.temp_config(compress: false) do
        built_names(1, 500, true).should eq ["sitemap.xml", "sitemap_index.xml"]
      end
    end
  end

  describe "with a custom sitemap_file_name" do
    it "uses it for a lone sitemap" do
      Sitemapper.temp_config(compress: false, sitemap_file_name: "urls") do
        built_names(1, 500, false).should eq ["urls.xml"]
      end
    end

    it "uses it for numbered sitemaps" do
      Sitemapper.temp_config(compress: false, sitemap_file_name: "urls") do
        built_names(3, 1, false).should eq ["urls1.xml", "urls2.xml", "urls3.xml"]
      end
    end

    it "references it from the index" do
      Sitemapper.temp_config(compress: false, sitemap_file_name: "urls", sitemap_host: "https://cdn.example.com") do
        index = built_index(2, 1)
        index.should contain "<loc>https://cdn.example.com/urls1.xml</loc>"
        index.should contain "<loc>https://cdn.example.com/urls2.xml</loc>"
      end
    end
  end

  describe "with a custom index_file_name" do
    it "uses it for the index file" do
      Sitemapper.temp_config(compress: false, index_file_name: "all_the_maps") do
        built_names(1, 500, true).should eq ["sitemap.xml", "all_the_maps.xml"]
      end
    end
  end

  describe "when streaming" do
    it "uses the configured names for the sitemaps and the index" do
      Sitemapper.temp_config(
        compress: false,
        use_index: true,
        storage: Sitemapper::LocalStorage,
        sitemap_file_name: "urls",
        index_file_name: "urls_index"
      ) do
        with_tempdir do |dir|
          written = Sitemapper.stream(max_urls: 2, storage_path: dir) do |builder|
            5.times { |i| builder.add("/posts/#{i}") }
          end

          written.should eq ["urls1.xml", "urls2.xml", "urls3.xml", "urls_index.xml"]
          Dir.glob("#{dir}/*.xml").map { |f| File.basename(f) }.sort!.should eq [
            "urls1.xml",
            "urls2.xml",
            "urls3.xml",
            "urls_index.xml",
          ]
          File.read("#{dir}/urls_index.xml").should contain "/urls3.xml</loc>"
        end
      end
    end
  end

  describe "with compress on" do
    it "lists the gzipped names in the index" do
      Sitemapper.temp_config(compress: true, sitemap_file_name: "urls", sitemap_host: "https://cdn.example.com") do
        built_index(2, 1).should contain "<loc>https://cdn.example.com/urls1.xml.gz</loc>"
      end
    end

    it "writes files matching the names the index lists" do
      Sitemapper.temp_config(
        compress: true,
        use_index: true,
        storage: Sitemapper::LocalStorage,
        sitemap_file_name: "urls",
        index_file_name: "urls_index"
      ) do
        with_tempdir do |dir|
          Sitemapper.stream(max_urls: 2, storage_path: dir) do |builder|
            3.times { |i| builder.add("/posts/#{i}") }
          end

          Dir.glob("#{dir}/*.gz").map { |f| File.basename(f) }.sort!.should eq [
            "urls1.xml.gz",
            "urls2.xml.gz",
            "urls_index.xml.gz",
          ]
        end
      end
    end
  end
end
