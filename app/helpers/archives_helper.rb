module ArchivesHelper
  def archive_action_link(archive)
    case archive.current_state.to_sym
    when :pending    then generate_button(archive)
    when :failed     then check_explanations_button(archive)
    when :generating then generation_loader(archive)
    when :ready      then download_button(archive)
    end
  end

  def download_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-download-alt}) + " Download Archive",
      archive.s3_url,
      class: %w{btn btn-sm btn-success},
      title: t(".generated_at", time: time_ago_in_words(archive.last_transition.updated_at))
    )
  end

  def generation_loader(archive)
    content_tag(:span,
      content_tag(:span, "", class: %w{glyphicon glyphicon-cog glyphicon-spin}) + " generating" + page_reload_script,
      title: t(".started_at", time: time_ago_in_words(archive.last_transition.updated_at))
    )
  end

  def page_reload_script(delay = 10_000)
    javascript_tag("setInterval(function(){window.location.reload(true);},#{delay});")
  end

  def generate_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-cog}) + " Generate Archive",
      archive,
      method: 'PUT',
      class: %w{btn btn-sm btn-primary}
    )
  end

  def check_explanations_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-repeat}) + " Try to generate again",
      archive,
      method: 'PUT',
      class: %w{btn btn-sm btn-danger},
      title: failure_reason(archive)
    )
  end

  def failure_reason(archive)
    if archive.transactions_left_to_explain == -1
      t(".missing_documents")
    else
      t(".missing_explanations", count: archive.transactions_left_to_explain)
    end
  end
end
