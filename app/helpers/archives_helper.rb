module ArchivesHelper
  def archive_action_link(archive)
    if archive.s3_url.present?
      download_button(archive)
    elsif archive.transactions_left_to_explain && archive.transactions_left_to_explain > 0
      transactions_left_to_explain_label(archive)
    else
      generate_button(archive)
    end
  end

  def download_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-download-alt}) + "Download Archive",
      archive.s3_url,
      class: %w{btn btn-sm btn-success}
    )
  end

  def transactions_left_to_explain_label(archive)
    content_tag(:span, "#{archive.transactions_left_to_explain} transactions left to explain", class: %w{label label-warning})
  end

  def generate_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-cog}) + "Generate Archive",
      archive,
      method: 'PUT',
      class: %w{btn btn-sm btn-primary}
    )
  end
end
