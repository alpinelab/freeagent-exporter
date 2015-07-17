class ArchiveDocument::Bill < ArchiveDocument::Base
  attr_reader :explanation

  def initialize(bill, explanation)
    @explanation = explanation
    super(bill)
  end

protected

  def filename
    @filename ||= "#{explanation.id}-#{type}.#{extension}"
  end
end
