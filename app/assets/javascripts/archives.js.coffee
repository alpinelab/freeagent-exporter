@reload_button = (id) ->
  setTimeout ( ->
    $.get "archives/#{id}", (data) ->
      $("#archive-#{id}").html(data)
  ), 5000

$ ->
  $('#select_all').click (event) ->
    $(':checkbox:not(:disabled)').each ->
      @checked = true
