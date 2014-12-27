GUI = null

$ ->
  GUI =
    selectedAxis: observable(null)

  $('.sidebar h1').on 'click', ->
    $(this).toggleClass('off').parents('.group').toggleClass('hidden')

  $("#minimum").on "change keyup paste input", ->
    GUI.selectedAxis().minVal($(@).val())

  GUI.selectedAxis.bind (v) ->
    if v is null
      $('#editAxis').slideUp()
      console.log 'axis unselected'
    else
      $("#minimum").val(v.minVal())
      $('#editAxis').slideDown()
      console.log 'axis selected'
