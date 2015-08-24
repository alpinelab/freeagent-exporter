module ArchivesHelper
  def archive_action_link(archive)
    case archive.current_state.to_sym
      when :pending    then generate_button(archive)
      when :failed     then check_explanations_button(archive)
      when :generating then generation_loader(archive)
      when :ready      then download_button(archive)
    end
  end

  def status_explanation(archive)
    case archive.current_state.to_sym
      when :failed      then failure_reason(archive)
      when :generating  then generating_since(archive)
    end
  end

  def other_action_link(archive)
    case archive.current_state.to_sym
      when :ready       then archive_delete_link(archive)
      when :generating  then archive_cancel_link(archive)
    end
  end

  def archive_cancel_link(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-remove}) + " Cancel",
      archive_action_path({id: archive.id, operation: :cancel}),
      class: %w{btn btn-sm btn-danger},
      method: :put,
      title: 'Cancel'
    )
  end

  def archive_delete_link(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-trash}) + " Delete Archive",
      archive_path(archive),
      class: %w{btn btn-sm btn-danger},
      method: :delete,
      data: { confirm: t("archives.index.delete_archive") },
      title: t("archives.index.delete_archive")
    )
  end

  def download_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-download-alt}) + " Download Archive",
      archive.s3_url,
      class: %w{btn btn-sm btn-success},
      title: t("archives.index.generated_at", time: time_ago_in_words(archive.last_transition.updated_at))
    )
  end

  def check_box(archive)
    check_box_tag(
      "archive_ids[#{archive.id}]",
      archive.id,
      false,
      disabled: archive.current_state.to_sym == :ready,
      autocomplete: 'off'
    )
  end

  def generation_loader(archive)
    content_tag(:span,
      content_tag(:span, "", class: %w{glyphicon glyphicon-cog glyphicon-spin}) + " generating" + reload_script(archive),
      title: generating_since(archive)
    )
  end

  def reload_script(archive)
    javascript_tag("reload_button(#{archive.id});")
  end

  def generate_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-cog}) + " Generate Archive",
      archive_action_path({id: archive.id, operation: :start}),
      method: :put,
      class: %w{btn btn-sm btn-primary}
    )
  end

  def check_explanations_button(archive)
    link_to(
      content_tag(:span, "", class: %w{glyphicon glyphicon-repeat}) + " Try to generate again",
      archive_action_path({id: archive.id, operation: :start}),
      method: :put,
      class: %w{btn btn-sm btn-warning},
      title: failure_reason(archive)
    )
  end

  def generating_since(archive)
     t("archives.index.started_at", time: time_ago_in_words(archive.last_transition.updated_at))
  end

  def failure_reason(archive)
    if archive.transactions_left_to_explain == -1
      t("archives.index.missing_documents")
    else
      t("archives.index.missing_explanations", count: archive.transactions_left_to_explain)
    end
  end
end
