class ArchiveDocument::Explanation < ArchiveDocument::Base

  def to_csv
    [document.dated_on, document.description, document.gross_value, full_path].to_csv
  end

protected

  def type
    @type ||= "bill"
  end
end
