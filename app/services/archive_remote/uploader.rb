class ArchiveRemote::Uploader < ArchiveRemote::Base
  attr_reader :archive, :zipfile

  def initialize(archive, zipfile)
    @zipfile = zipfile
    super(archive)
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

end
