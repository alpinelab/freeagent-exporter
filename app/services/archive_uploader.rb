class Uploader
  attr_reader :archive, :file_path

  def initialize(archive, file_path)
    @archive = archive
    @file_path = file_path
  end

  def call
    s3_obj.upload_file(file_path)
    s3_obj.public_url
  end

  def self.call(archive, file_path)
    new(archive, file_path).call
  end

protected

  def filename
    @filename ||= File.basename(file_path)
  end

  def s3_path
    @s3_path ||= "#{archive.bank_account.id}/#{filename}"
  end

  def s3_bucket_name
    @s3_bucket_name ||= Rails.application.secrets.aws_s3_bucket_name
  end

  def s3_obj
    @s3_obj ||= Aws::S3::Resource.new.bucket(s3_bucket_name).object(s3_path)
  end
end
