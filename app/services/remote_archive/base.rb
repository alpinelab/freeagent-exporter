module RemoteArchive::Base

  def initialize(archive)
    @archive = archive
  end

protected

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
