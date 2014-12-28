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

  $("#interval").on "change keyup paste input", ->
    v = parseFloat $(@).val()
    if v > 0
      GUI.selectedAxis()?.interval(v)

  GUI.selectedAxis.subscribe (v, old) ->
    if v is null
      old?.minVal.unbind($('#minimum'))
      old?.maxVal.unbind($('#maximum'))
      old?.type.unbind($('#type'))
      $('#editAxis').slideUp()
      console.log 'axis unselected'
    else
      GUI.selectedAxis().minVal.bind($('#minimum'), (v) -> parseFloat(v))
      GUI.selectedAxis().maxVal.bind($('#maximum'), (v) -> parseFloat(v))
      GUI.selectedAxis().type.bind($('#type'))

      $("#interval").val(v.interval())

      $('#editAxis').slideDown()
      console.log 'axis selected'
