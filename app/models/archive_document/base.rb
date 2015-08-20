require 'open-uri'

class ArchiveDocument::Base
  attr_reader :document

  def initialize(document)
    @document = document
  end


  def add_to_archive_and_csv(zipfile, csv)
    return if content.nil?

    add_to_archive(zipfile)
    add_to_csv(csv)
  end

protected

  def add_to_csv(csv)
    csv << to_csv
  end

  def add_to_archive(zipfile)
    zipfile.file.open(full_path, "w") do |file|
      file << content
    end
    zipfile.commit

  end

  def full_path
    "#{path}/#{filename}"
  end

  def filename
    @filename ||= "#{document.id}-#{type}.#{extension}"
  end

  def type
    @type ||= document.class.name.demodulize.parameterize
  end

  def content
    @content ||= open(document.attachment.content_src).read unless document.attachment.nil?
  end

  def content_type
    @content_type ||= document.attachment.content_type unless document.attachment.nil?
  end

  def path
    @path ||= type.pluralize
  end

  def extension
    @extension ||= case content_type
    when "image/jpeg"      then "jpeg"
    when "image/jpg"       then "jpg"
    when "image/png"       then "png"
    when "application/pdf" then "pdf"
    when nil               then "unknown"
    else content_type.split("/").last
    end
  end
end
