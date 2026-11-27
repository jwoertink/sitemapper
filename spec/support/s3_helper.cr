require "http/server"

module S3Helper
  record S3Upload, path : String, content_type : String?, body : Bytes

  def with_fake_s3(&)
    uploads = [] of S3Upload
    server = HTTP::Server.new do |context|
      body = context.request.body.try(&.getb_to_end) || Bytes.empty
      uploads << S3Upload.new(context.request.path, context.request.headers["Content-Type"]?, body)
      context.response.headers["ETag"] = %("etag")
    end
    address = server.bind_tcp("127.0.0.1", 0)
    spawn { server.listen }
    begin
      yield "http://127.0.0.1:#{address.port}", uploads
    ensure
      server.close
    end
  end
end
