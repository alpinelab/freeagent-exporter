jQuery ->
  $(".archive .status-button").on "ajax:success", (e, data, status, xhr) ->
    interval = setInterval (->
      $.get "archives/#{data.id}", (data) ->
        $(e.currentTarget).html(data)
        if data.indexOf("generating") == -1
          clearInterval(interval);
        return
    ), 2000
