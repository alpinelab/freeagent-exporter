class RemoteArchive::Destroyer
  include RemoteArchive::Base
  attr_reader :archive

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
end
