class ArchiveDocument::Bill < ArchiveDocument::Base
  attr_reader :explanation

  def initialize(bill, explanation)
    @explanation = explanation
    super(bill)
  end

  def to_csv
    [document.dated_on, document.reference, document.total_value, full_path].to_csv
  end

protected

  def filename
    @filename ||= "#{explanation.id}-#{type}.#{extension}"
  end
end
