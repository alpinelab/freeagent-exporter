class ArchiveExplanation < ArchiveDocument

protected

  def type
    @type ||= "bill"
  end
end
