class ArchiveDocument::Expense < ArchiveDocument::Base

  def to_csv
    [document.dated_on, document.description, document.gross_value, full_path].to_csv
  end

protected

  def path
    @path ||= "expenses/" + "#{document.user.first_name} #{document.user.last_name}"
  end
end
