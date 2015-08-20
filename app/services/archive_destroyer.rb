class ArchiveDestroyer
  attr_reader :archive

  def initialize(archive)
    @archive = archive
  end

  def call
    return if archive.s3_url.nil?
    s3_obj.delete()
    archive.update_attributes(s3_url: nil)
  end

  def self.call(archive)
    new(archive).call
  end

protected

  def filename
    @filename ||= File.basename(archive.s3_url)
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
