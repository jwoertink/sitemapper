require "awscr-s3"

module Sitemapper
  class AwsStorage < Storage
    getter client : Awscr::S3::Client

    def initialize(@sitemaps : Sitemaps)
      super(@sitemaps)
      if Sitemapper.config.storage != :aws || Sitemapper.config.aws_config.nil?
        raise Sitemapper::ConfigurationError.new("`config.storage` must be set to `:aws`, and the `config.aws_config` options must be set")
      end
      config = Sitemapper.config.aws_config.not_nil!
      @client = Awscr::S3::Client.new(
        region: config["region"].as(String),
        aws_access_key: config["key"].as(String),
        aws_secret_key: config["secret"].as(String)
      )
    end

    # `path` is the bucket path
    # "my-prod-bucket/sitemaps/mycoolsite"
    def save(path : String)
      sitemaps.each do |sitemap|
        client.put_object(path, sitemap["name"].to_s, sitemap["data"].to_s, {"x-amz-acl" => "public-read", "Content-Type" => "application/xml"})
      end
    end
  end
end
