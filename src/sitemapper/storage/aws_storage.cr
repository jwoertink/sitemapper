require "awscr-s3"
require "../aws_storage_config"

module Sitemapper
  class AwsStorage < Storage
    getter client : Awscr::S3::Client

    def initialize(@sitemaps : Sitemaps)
      super(@sitemaps)
      if Sitemapper.config.aws_config.nil?
        raise Sitemapper::ConfigurationError.new("`config.storage` must be set to `Sitemapper::AwsStorage`, and `config.aws_config` must be configured with `AwsStorageConfig`")
      end
      config = Sitemapper.config.aws_config.not_nil!
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
      sitemaps.each do |sitemap|
        client.put_object(path, sitemap["name"].to_s, sitemap["data"].to_s, {"x-amz-acl" => "public-read", "Content-Type" => "application/xml"})
      end
    end
  end
end
