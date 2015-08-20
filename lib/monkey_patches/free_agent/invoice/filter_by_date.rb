module MonkeyPatches
  module FreeAgent
    module Invoice
      module FilterByDate
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def filter_by_date(from, to)
            ::FreeAgent::Invoice.filter(nested_invoice_items: 'true').reject { |invoice| invoice.dated_on < from || invoice.dated_on > to }
          end
        end
      end
    end
  end
end

