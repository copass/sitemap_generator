begin
  require 's3'
rescue LoadError
  raise LoadError.new("Missing required 's3'.  Please 'gem install s3' and require it in your application.")
end

module SitemapGenerator
  class MyS3Adapter

    def initialize(opts = {})
      @aws_access_key_id = opts[:aws_access_key_id] || ENV['AWS_ACCESS_KEY_ID']
      @aws_secret_access_key = opts[:aws_secret_access_key] || ENV['AWS_SECRET_ACCESS_KEY']
      @aws_bucket = opts[:aws_bucket]
    end

    # Call with a SitemapLocation and string data
    def write(location, raw_data)
      SitemapGenerator::FileAdapter.new.write(location, raw_data)
      amazon = S3::Service.new(access_key_id: @aws_access_key_id, secret_access_key: @aws_secret_access_key)
      bucket = amazon.buckets.find(@aws_bucket)

      file = bucket.objects.build("#{location.sitemaps_path}#{location.filename}")
      file.content = File.read(location.path)
      if file.save
        puts "Sitemap sent to #{file.url}"
      end
    end

  end
end
