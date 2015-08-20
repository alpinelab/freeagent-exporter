@reload_button = (id) ->
  setTimeout ( ->
    $.get "archives/#{id}", (data) ->
      $("#archive-#{id}").html(data)
  ), 5000
