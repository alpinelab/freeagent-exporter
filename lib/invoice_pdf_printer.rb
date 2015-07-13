class InvoicePdfPrinter

  def self.haml_template
    @haml_template ||= Haml::Engine.new(template_file)
  end

  def self.template_file
    @template_file ||= File.read('app/views/invoices/show.html.haml')
  end

  def self.template_options
    { stylesheet: Rails.application.assets.find_asset('application.css').to_s.html_safe }
  end

  def self.invoice_to_pdf(invoice)
    PDFKit.new(
      haml_template.render(
        invoice,
        template_options
      )
    ).to_pdf
  end

  def self.invoice_to_html(invoice)
    haml_template.render(
      invoice,
      template_options
    )
  end
end
