class ArchiveExpense < ArchiveDocument

protected

  def path
    @path ||= "expenses/" + "#{document.user.first_name} #{document.user.last_name}"
  end
end
