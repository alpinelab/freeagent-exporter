module FreeAgent
  class Invoice < Resource
    def self.filter_by_time(from, to)
      FreeAgent::Invoice.filter(nested_invoice_items: 'true').reject { |invoice| invoice.due_on < from || invoice.due_on > to }
    end
  end
end
