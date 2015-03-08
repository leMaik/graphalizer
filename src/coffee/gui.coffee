class GraphalizerViewModel
  constructor: ->
    @axes = AXES
    @points = POINTS
    @selectedAxis = ko.observable(null)
    @isAxisSelected = ko.computed => @selectedAxis isnt null

    @mode = ko.observable('setup')
    @mode.subscribe (mode) =>
      if mode isnt 'setup'
        axis.isEditing(no) for axis in @axes()
        doc.isEditing(no) for doc in IMAGES

  exportCsv: =>
    csv = ''
    for axis in @axes()
      csv += axis.name() + ';'
    csv += '\n'
    for point in @points()
      for v in point.values()
        csv += v + ';'
      csv += '\n'

    saveAs(new Blob([csv], {type: 'application/csv'}), 'graphalizer.csv')

  addVerticalAxis: ->
    newAxis = new VerticalAxis()
    newAxis.name 'Achse ' + (@axes().length + 1)
    @axes.push newAxis

  addHorizontalAxis: ->
    newAxis = new HorizontalAxis()
    newAxis.name 'Achse ' + (@axes().length + 1)
    @axes.push newAxis

  template: (name, vars) ->
    __templates[name](vars)

GUI = null
$ ->
  GUI = new GraphalizerViewModel()
  ko.applyBindings(GUI)

  GUI.showWindow = (content) ->
    overlay = $('<div class="overlay"><div class="window"/></div>').hide().appendTo('body')
    new TemplateWrapper overlay.fadeIn(200).find('.window').html(content)

  GUI.closeWindow = ->
    $('.overlay').fadeOut 200
    $('.overlay *').off() #make sure all event handlers are detached
    ko.cleanNode $('.overlay')[0]

  $('#setupModeSelector').on 'click', ->
    $(this).parent().children('.active').removeClass('active')
    $(this).addClass('active')
    GUI.mode 'setup'

  $('#analyzeModeSelector').on 'click', ->
    $(this).parent().children('.active').removeClass('active')
    $(this).addClass('active')
    GUI.mode 'analyze'

  $('#markModeSelector').on 'click', ->
    $(this).parent().children('.active').removeClass('active')
    $(this).addClass('active')
    GUI.mode 'mark'

  toggleGroup = (group) ->
    group.find('h1').toggleClass('on')
    ctn = group.find('.ctn')
    if ctn.is(":visible") then ctn.slideUp() else ctn.slideDown()

  $('.sidebar .group:not(.notmanual) h1').on 'click', ->
    toggleGroup $(@).parent()

class TemplateWrapper
  constructor: (@rootNode) ->
  get: (id) =>
    @rootNode.find('*[data-id=' + id + ']')
  root: => @rootNode[0]