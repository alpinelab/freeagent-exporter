class ArchiveUploader
  attr_reader :archive, :zipfile

  def initialize(archive, zipfile)
    @archive = archive
    @zipfile = zipfile
  end

  def call
    archive.update_attributes(s3_url: s3_obj.public_url) if s3_obj.upload_file(zipfile.name)
  end

  def self.call(archive, zipfile)
    new(archive, zipfile).call
  end

protected

  def filename
    @filename ||= File.basename(zipfile.name)
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
