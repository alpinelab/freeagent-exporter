$ ->
  $('.ui.dropdown').dropdown()
  $('.message .close').on 'click', ->
    $(@).closest('.message').transition('fade')
