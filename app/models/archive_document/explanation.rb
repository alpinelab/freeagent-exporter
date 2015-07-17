class ArchiveDocument::Explanation < ArchiveDocument::Base

protected

  def type
    @type ||= "bill"
  end
end
