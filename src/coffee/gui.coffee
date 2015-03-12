class GraphalizerViewModel
  constructor: ->
    @axes = AXES
    @points = POINTS
    @selectedAxis = ko.observable(null)
    @isAxisSelected = ko.computed => @selectedAxis() isnt null
    @markRadius = ko.observable 20

    @mode = ko.observable('setup')
    @mode.subscribe (mode) =>
      if mode isnt 'setup'
        axis.isEditing(no) for axis in @axes()
        doc.isEditing(no) for doc in IMAGES

      if mode is 'mark'
        img.showMarkings() for img in IMAGES
      else
        img.hideMarkings() for img in IMAGES

  removeAllPoints: =>
    p.remove() for p in @points().slice() #iterate over copy
    Layers.POINTS.draw()
    return

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

  removeMarkings: ->
    img.removeMarkings() for img in IMAGES

  addVerticalAxis: ->
    newAxis = new VerticalAxis()
    newAxis.name 'Achse ' + (@axes().length + 1)
    @axes.push newAxis

  addHorizontalAxis: ->
    newAxis = new HorizontalAxis()
    newAxis.name 'Achse ' + (@axes().length + 1)
    @axes.push newAxis

  analyzeDocuments: ->
    for image in IMAGES
      image.analyze()

  moveLeft: (axis) =>
    i = @axes().indexOf(axis)
    if i > 0 #if not first
      tmp = @axes()[i]
      @axes()[i] = @axes()[i - 1]
      @axes()[i - 1] = tmp
      @axes.valueHasMutated()

  moveRight: (axis) =>
    i = @axes().indexOf(axis)
    if i < @axes().length - 1 #if not last
      tmp = @axes()[i]
      @axes()[i] = @axes()[i + 1]
      @axes()[i + 1] = tmp
      @axes.valueHasMutated()

  leftMost: (axis) =>
    @axes().indexOf(axis) > 0

  rightMost: (axis) =>
    @axes().indexOf(axis) < @axes().length - 1

  showResultsWindow: =>
    window = GUI.showWindow GUI.template('resultsWindow'), $('#analyzeGroup')
    ko.applyBindings(this, window.root())

  template: (name, vars) ->
    __templates[name](vars)

  showAboutDialog: ->
    class aboutVm
      constructor: ->
        @credits = Credits.credits

        window = GUI.showWindow GUI.template('about')
        ko.applyBindings(this, window.root())

      close: ->
        GUI.closeWindow()
    new aboutVm()

GUI = null
$ ->
  GUI = new GraphalizerViewModel()
  ko.applyBindings(GUI)

  GUI.showWindow = (content, fadeFrom) ->
    GUI._currentWindowFrom = fadeFrom
    overlay = $('<div class="overlay"><div class="window"/></div>').hide().appendTo('body')
    w = overlay.fadeIn(200).find('.window').html(content)
    targetWidth = w.width()
    targetHeight = w.height()
    if fadeFrom?
      fadeFrom.css("position", "absolute")
      w.find('.scroll').css('max-height', '100%')
      w.width(fadeFrom.width() - 30).height(fadeFrom.height() - 40)
      .css({position: 'absolute', left: fadeFrom.offset().left, top: fadeFrom.offset().top - 100})
      .animate
          width: targetWidth
          height: 0.8 * window.innerHeight
          top: 0
          left: (window.innerWidth - targetWidth) / 2
        , 500
      fadeFrom.css("position", null).fadeOut(100)
      console.log targetWidth
    new TemplateWrapper w

  GUI.closeWindow = ->
    if GUI._currentWindowFrom?
      fadeFrom = GUI._currentWindowFrom
      w = $('.overlay').find('.window').css('overflow', 'hidden')
      fadeFrom.css("position", "absolute").show()
      console.log fadeFrom.offset()
      w.animate
        width: fadeFrom.width() + 20
        height: fadeFrom.height() + 10
        top: fadeFrom.offset().top - 100 #100 is marginTop
        left: fadeFrom.offset().left
      , 500, ->
        $('.overlay').fadeOut(100)
        fadeFrom.show()
      fadeFrom.hide().css("position", null)
      delete GUI._currentWindowFrom
    else
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

  $('#canvas').bind 'wheel', (event) ->
    if GUI.mode() is 'mark'
      if event.originalEvent.wheelDelta < 0 or event.originalEvent.detail > 0
        GUI.markRadius Math.max(GUI.markRadius() - 1, 1)
      else
        GUI.markRadius GUI.markRadius() + 1

class TemplateWrapper
  constructor: (@rootNode) ->
  get: (id) =>
    @rootNode.find('*[data-id=' + id + ']')
  root: => @rootNode[0]