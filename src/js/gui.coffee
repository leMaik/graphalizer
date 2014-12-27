GUI = null

$ ->
  GUI =
    selectedAxis: observable(null)

  $('.sidebar h1').on 'click', ->
    $(this).toggleClass('off').parents('.group').toggleClass('hidden')

  $("#minimum").on "change keyup paste input", ->
    GUI.selectedAxis().minVal(parseFloat $(@).val())
  $("#maximum").on "change keyup paste input", ->
    GUI.selectedAxis().maxVal(parseFloat $(@).val())
  $("#interval").on "change keyup paste input", ->
    v = parseFloat $(@).val()
    if v > 0
      GUI.selectedAxis().interval(v)
    return true

  GUI.selectedAxis.bind (v) ->
    if v is null
      $('#editAxis').slideUp()
      console.log 'axis unselected'
    else
      $("#minimum").val(v.minVal())
      $("#maximum").val(v.maxVal())
      $("#interval").val(v.interval())
      $('#editAxis').slideDown()
      console.log 'axis selected'
