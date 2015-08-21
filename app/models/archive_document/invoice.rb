class ArchiveDocument::Invoice < ArchiveDocument::Base

  def to_csv
    [document.dated_on, document.reference, document.net_value, full_path].to_csv
  end

protected

  def content
    @content ||= InvoicePdfPrinter.invoice_to_pdf(document)
  end

  def content_type
    @content_type ||= "application/pdf"
  end

  def filename
    @filename ||= "invoice_#{document.id}.pdf" unless document.nil?
  end
end
