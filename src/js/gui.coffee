GUI = null

$ ->
  GUI =
    selectedAxis: observable(null)
    mode: observable('setup')
    template: (name, vars) -> __templates[name](vars)

  GUI.mode.subscribe (mode) ->
    if mode is 'analyze'
      axis.isEditing(no) for axis in AXES
      doc.isEditing(no) for doc in IMAGES

  GUI.showWindow = (content) ->
    overlay = $('<div class="overlay"><div class="window"/></div>').hide().appendTo('body')
    new TemplateWrapper overlay.fadeIn(200).find('.window').html(content)

  GUI.closeWindow = ->
    $('.overlay').fadeOut 200
    $('.overlay *').off() #make sure all event handlers are detached

  $('#setupModeSelector').on 'click', ->
    $(this).parent().children('.active').removeClass('active')
    $(this).addClass('active')
    GUI.mode 'setup'

  $('#analyzeModeSelector').on 'click', ->
    $(this).parent().children('.active').removeClass('active')
    $(this).addClass('active')
    GUI.mode 'analyze'

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

  $('#newVAxis').on 'click', ->
    newAxis = new VerticalAxis()
    newAxis.name 'Achse ' + (AXES.length + 1)
    AXES.push newAxis
  $('#newHAxis').on 'click', ->
    newAxis = new HorizontalAxis()
    newAxis.name 'Achse ' + (AXES.length + 1)
    AXES.push newAxis

  $('#deleteAxis').on 'click', ->
    GUI.selectedAxis().remove()

  GUI.selectedAxis.subscribe (v, old) ->
    if v is null
      old?.minVal.unbind($('#minimum'))
      old?.maxVal.unbind($('#maximum'))
      old?.type.unbind($('#type'))
      old?.name.unbind($('#name'))
      $('#editAxis').slideUp()
      console.log 'axis unselected'
    else
      GUI.selectedAxis().minVal.bind($('#minimum'), (v) -> parseFloat(v))
      GUI.selectedAxis().maxVal.bind($('#maximum'), (v) -> parseFloat(v))
      GUI.selectedAxis().type.bind($('#type'))
      GUI.selectedAxis().name.bind($('#name'))

      $('#interval').val(v.interval())

      $('#editAxis').slideDown()
      console.log 'axis selected'

class TemplateWrapper
  constructor: (@rootNode) ->
  get: (id) =>
    @rootNode.find('*[data-id=' + id + ']')