class ArchiveInvoice < ArchiveDocument

protected

  def content
    @content ||= InvoicePdfPrinter.invoice_to_pdf(document)
  end

  def content_type
    @content_type ||= "application/pdf"
  end

  def path
    @path ||= "invoice_#{document.id}.pdf" unless document.nil?
  end
end
