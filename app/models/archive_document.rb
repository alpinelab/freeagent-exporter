class ArchiveDocument
  attr_reader :document, :explanation

  def initialize(document, explanation = nil)
    @document    = document
    @explanation = explanation
  end

  def add_to_archive(zipfile)
    unless document.attachment.nil?
      zipfile.file.open("#{path}/#{filename}", "w") do |file|
        file << open(document.attachment.content_src).read
      end
      zipfile.commit
    end
  end

protected

  def filename
    "#{filename_id}-#{type}.#{extension}"
  end

  def filename_id
    explanation.present? ? explanation.id : document.id
  end

  def type
    if document.is_a? FreeAgent::BankTransactionExplanation
      "bill"
    else
      document.class.name.demodulize.parameterize
    end
  end

  def path
    type.pluralize
  end

  def extension
    @extension ||= case document.attachment.content_type
    when "image/jpeg"      then "jpeg"
    when "image/jpg"       then "jpg"
    when "image/png"       then "png"
    when "application/pdf" then "pdf"
    else document.attachment.content_type.split("/").last
    end
  end
end
