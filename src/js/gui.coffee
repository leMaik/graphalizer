$ ->
  $('.sidebar h1').on 'click', ->
    $(this).toggleClass('off').parents('.group').toggleClass('hidden')