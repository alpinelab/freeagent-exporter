module ArchivesHelper
  def link_to_archive_or_generate archive
    archive.s3_url.present? ? link_to("Download Archive", archive.s3_url) : link_to("Generate Archive", archive, method: 'PUT')
  end
end
