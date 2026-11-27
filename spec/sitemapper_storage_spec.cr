require "./spec_helper"

include S3Helper

describe Sitemapper::Storage do
  describe "with local storage" do
    describe "with compress" do
      it "writes sitemap.xml.gz" do
        with_tempdir do |dir|
          storage = Sitemapper::LocalStorage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}])
          storage.save(dir)
          File.exists?("#{dir}/sitemap.xml.gz").should be_true
          File.size("#{dir}/sitemap.xml.gz").should be > 1
        end
      end
    end

    describe "without compress" do
      it "writes sitemap.xml" do
        Sitemapper.temp_config(compress: false) do
          with_tempdir do |dir|
            storage = Sitemapper::LocalStorage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}])
            storage.save(dir)
            File.exists?("#{dir}/sitemap.xml").should be_true
            File.size("#{dir}/sitemap.xml").should be > 1
          end
        end
      end
    end
  end

  describe "with aws storage" do
    it "raises an exception if not configured properly" do
      expect_raises(Sitemapper::ConfigurationError) do
        Sitemapper::AwsStorage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}])
      end
    end

    it "creates the client with proper config" do
      Sitemapper.temp_config(
        storage: Sitemapper::AwsStorage,
        aws_config: AwsStorageConfig.new(region: "us-west-1", key: "AWSKEY", secret: "AWSSECRET", endpoint: "https://mycustomendpoint.s3.us-east-1.amazonaws.com/")
      ) do
        store = Sitemapper::AwsStorage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}])
        store.client.should be_a Awscr::S3::Client
      end
    end

    describe "with compress" do
      it "uploads gzipped data to sitemap.xml.gz" do
        with_fake_s3 do |endpoint, uploads|
          Sitemapper.temp_config(
            storage: Sitemapper::AwsStorage,
            aws_config: AwsStorageConfig.new(region: "us-west-1", key: "AWSKEY", secret: "AWSSECRET", endpoint: endpoint)
          ) do
            storage = Sitemapper::AwsStorage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}])
            storage.save("my-bucket/sitemaps")

            uploads.size.should eq 1
            uploads.first.path.should eq "/my-bucket/sitemaps/sitemap.xml.gz"
            uploads.first.content_type.should eq "application/gzip"
            Compress::Gzip::Reader.open(IO::Memory.new(uploads.first.body), &.gets_to_end).should eq "<XML></XML>"
          end
        end
      end
    end

    describe "without compress" do
      it "uploads plain xml to sitemap.xml" do
        with_fake_s3 do |endpoint, uploads|
          Sitemapper.temp_config(
            compress: false,
            storage: Sitemapper::AwsStorage,
            aws_config: AwsStorageConfig.new(region: "us-west-1", key: "AWSKEY", secret: "AWSSECRET", endpoint: endpoint)
          ) do
            storage = Sitemapper::AwsStorage.new([{"name" => "sitemap.xml", "data" => "<XML></XML>"}])
            storage.save("my-bucket/sitemaps")

            uploads.size.should eq 1
            uploads.first.path.should eq "/my-bucket/sitemaps/sitemap.xml"
            uploads.first.content_type.should eq "application/xml"
            String.new(uploads.first.body).should eq "<XML></XML>"
          end
        end
      end
    end
  end
end
