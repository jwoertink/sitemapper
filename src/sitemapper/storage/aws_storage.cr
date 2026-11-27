require "awscr-s3"
require "compress/gzip"
require "../aws_storage_config"

module Sitemapper
  class AwsStorage < Storage
    getter client : Awscr::S3::Client

    def initialize(@sitemaps : Sitemaps)
      super(@sitemaps)
      if Sitemapper.config.aws_config.nil?
        raise Sitemapper::ConfigurationError.new("`config.storage` must be set to `Sitemapper::AwsStorage`, and `config.aws_config` must be configured with `AwsStorageConfig`")
      end
      config = Sitemapper.config.aws_config.as(AwsStorageConfig)
      @client = Awscr::S3::Client.new(
        region: config.region,
        aws_access_key: config.key,
        aws_secret_key: config.secret,
        endpoint: config.endpoint
      )
    end

    # `path` is the bucket path
    # "my-prod-bucket/sitemaps/mycoolsite"
    def save(path : String) : Nil
      if Sitemapper.config.compress
        sitemaps.each do |sitemap|
          put_compressed_sitemap(path, sitemap)
        end
      else
        sitemaps.each do |sitemap|
          put_sitemap(path, sitemap)
        end
      end
    end

    private def put_sitemap(path, sitemap)
      client.put_object(path, sitemap["name"], sitemap["data"], {"x-amz-acl" => "public-read", "Content-Type" => "application/xml"})
    end

    private def put_compressed_sitemap(path, sitemap)
      io = IO::Memory.new
      Compress::Gzip::Writer.open(io) do |gzip|
        gzip << sitemap["data"]
      end
      client.put_object(path, Sitemapper.stored_file_name(sitemap["name"]), io.to_slice, {"x-amz-acl" => "public-read", "Content-Type" => "application/gzip"})
    end
  end
end
