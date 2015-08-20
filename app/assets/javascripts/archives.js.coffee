@reload_button = (id) ->
  setTimeout ( ->
    $.get "archives/#{id}", (data) ->
      $("#button-#{id}").html(data)
  ), 5000
