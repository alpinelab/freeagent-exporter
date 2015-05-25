module ArchivesHelper
  def link_to_archive_or_generate archive
    if archive.s3_url.present?
      link_to("Download Archive", archive.s3_url)
    else
      link_to("Generate Archive", archive, method: 'PUT')
    end
  end
end
