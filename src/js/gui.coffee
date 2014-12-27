GUI = null

$ ->
  GUI =
    selectedAxis: observable(null)

  $('.sidebar h1').on 'click', ->
    $(@).toggleClass('on');
    ctn = $(@).parent().find('.ctn')
    if ctn.is(":visible") then ctn.slideUp() else ctn.slideDown()

  $('.sidebar .group .ctn').hide()

  $("#name").on "change keyup paste input", ->
    if $(@).val() is "rezilahparG"
      $('body').css 'transform', 'rotateY(180deg)'
      return

  $("#minimum").on "change keyup paste input", ->
    GUI.selectedAxis().minVal(parseFloat $(@).val())

  $("#maximum").on "change keyup paste input", ->
    GUI.selectedAxis().maxVal(parseFloat $(@).val())

  $("#interval").on "change keyup paste input", ->
    v = parseFloat $(@).val()
    if v > 0
      GUI.selectedAxis()?.interval(v)

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
