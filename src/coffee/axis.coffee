#Code for axes
class Axis
  constructor: ->
    @name = ko.observable('')
    @minVal = ko.numericObservable(0)
    @minVal.subscribe(@resetMarks)
    @maxVal = ko.numericObservable(100)
    @maxVal.subscribe(@resetMarks)
    @interval = ko.numericObservable(10)
    @interval.subscribe(@resetMarks)
    @type = ko.observable("linear")
    @type.subscribe (v) =>
      if v is "logarithmic" and @minVal() is 0
        @minVal(0.1)
      @resetMarks()
    @axisMode = ko.observable('')
    @axisMode.subscribe (v) =>
      @resetMarks()

    @lineSize = ko.observable()
    @lineX = ko.observable(50)
    @lineY = ko.observable(50)
    @lineSize.subscribe => @resetMarks()
    @lineX.subscribe => @resetMarks()
    @lineY.subscribe => @resetMarks()

    @marks = []
    @controls = {}
    @isEditing = ko.observable(no)
    @isEditing.subscribe (v) =>
      if v
        deselectAllExcept(@)
        @line.shadowBlur(15)
      else
        @line.shadowBlur(0)
      Layers.AXES.draw()
      GUI.selectedAxis(if v then @ else null)
    Layers.AXES.add @axis = new Kinetic.Group

    @line = @getLine()
    .shadowColor('black')
    .shadowBlur(0)
    .shadowOpacity(1)
    .on 'mouseover', =>
      if !@isEditing()
        @line.shadowBlur(5)
        Layers.AXES.draw()
    .on 'mouseout', =>
      if !@isEditing()
        @line.shadowBlur(0)
        Layers.AXES.draw()

    @axis.add(@line).draw()

    @isFirst = ko.computed =>
      GUI.axes().indexOf(@) == 0

    @isLast = ko.computed =>
      GUI.axes().indexOf(@) == GUI.axes().length - 1

  getMarks: =>
    if @type() is "logarithmic"
      marks = []
      if @minVal() is 0
        return marks

      switch @axisMode()
        when "x2"
          v = @minVal()
          while v <= @maxVal()
            marks.push
              px: @transform v
              val: v
            v *= 2
        when "x10"
          v = @minVal()
          while v <= @maxVal()
            marks.push
              px: @transform v
              val: v
            v *= 10
        else
          v = @minVal()
          f = Math.pow(10, Math.floor Util::log10 v) #major pitfall! Math.log == ln
          while v <= @maxVal()
            for i in [1..10]
              v = f * i
              if @minVal() <= v <= @maxVal()
                marks.push
                  px: @transform v
                  val: v
            f *= 10
      return marks
    else if @type() is "linear"
      marks = []
      if @interval() isnt 0
        pos = 0
        v = @minVal()
        while v <= @maxVal()
          marks.push
            px: @transform v
            val: v
          v += @interval()
      return marks
    else
      console.error "Unknown axis type"

  resetMarks: =>
    mark.remove() for mark in @marks
    @createMarks()

  remove: =>
    @axis.remove()
    AXES.remove(@) #remove this axis from the array
    if @isEditing()
      @isEditing(no)


class HorizontalAxis extends Axis
  constructor: ->
    super()

    @isEditing.subscribe (v) =>
      if v
        @controls.minCirc = ImageCircle
          size: 20
          image: 'res/left.svg'
          x: @line.x()
          y: @line.y() + 40
          tooltip: 'Ziehen zum verschieben'
        .on 'dragmove', =>
          @line.scaleX(@line.scaleX() - @controls.minCirc.x() + @line.x())
          @line.x(@controls.minCirc.x())
          @controls.minCirc.y(@line.y() + 40)
          @lineSize @line.scaleX()
          @lineX @line.x()
          @resetMarks()
        @controls.maxCirc = ImageCircle
          size: 20
          image: 'res/right.svg'
          x: @line.x() + @line.scaleX()
          y: @line.y() + 40
          tooltip: 'Ziehen zum verschieben'
        .on 'dragmove', =>
          @line.scaleX(@controls.maxCirc.x() - @line.x())
          @controls.maxCirc.y(@line.y() + 40)
          @lineSize @line.scaleX()
          @resetMarks()
        Layers.AXES.add(@controls[c]) for c of @controls
      else
        @controls[c].remove() for c of @controls
      Layers.AXES.draw()

  getLine: =>
    @line = new Kinetic.Rect
      fill: Colors.primary
      width: 1
      height: 2
      draggable: yes
      scaleX: STAGE.width() - 100
      x: 50
      y: 50
      hitFunc: (context) ->
        context.beginPath()
        context.rect(0, -10, 1, 20)
        context.closePath()
        context.fillStrokeShape(@)
    .on 'dragmove', =>
      @lineX @line.x()
      @lineY @line.y()
      if @isEditing()
        @controls.minCirc.x(@lineX()).y(@lineY() + 40)
        @controls.maxCirc.x(@lineX() + @lineSize()).y(@lineY() + 40)
    .on 'mouseenter', ->
      $('body').css('cursor', 'move')
    .on 'mouseleave', =>
      $('body').css('cursor', '')
    .on 'click', =>
      @isEditing(!@isEditing())

    @lineSize STAGE.width() - 100
    return @line

  createMarks: =>
    for mark in @getMarks()
      a = new Kinetic.Line
        points: [0, 0, 0, 10]
        stroke: Colors.primary
        strokeWidth: 1
        draggable: no
        x: mark.px
        y: @line.y() - 5
      txt = new Kinetic.Text
        x: mark.px - 5
        y: @line.y() + 7
        text: mark.val.toFixed(2)
        fontSize: 10
        fontFamily: 'sans-serif'
        fill: Colors.primary
      @axis.add(a).add(txt)
      @marks.push a
      @marks.push txt
    Layers.AXES.draw()

  #source: http://www.ibrtses.com/delphi/dmcs.html
  transformToValue: (x) =>
    if @type() is "linear"
      return (@maxVal() - @minVal()) / @lineSize() * (x - @lineX()) + @minVal()
    else if @type() is "logarithmic"
      return @minVal() * Math.exp(((x - @lineX()) / @lineSize()) * Math.log(@maxVal() / @minVal()) / Math.log(Math.E))
    else
      console.error "Unknown axis type"

  transform: (x) =>
    if @type() is "linear"
      console.log "linear"
      return @lineX() + (@lineSize() / (@maxVal() - @minVal())) * (x - @minVal())
    else if @type() is "logarithmic"
      return @lineX() + Math.round(Math.log(x / @minVal()) / Math.log(@maxVal() / @minVal()) * @lineSize())
    else
      console.error "Unknown axis type"

  valueAt: (x, y) =>
    if @type() is 'linear'
      return @transformToValue x
    if @type() is 'logarithmic'
      return @transformToValue x

class VerticalAxis extends Axis
  constructor: ->
    super()

    @isEditing.subscribe (v) =>
      if v
        @controls.maxCirc = ImageCircle
          size: 20
          image: 'res/up.svg'
          x: @line.x() - 40
          y: @line.y()
          tooltip: 'Ziehen zum verschieben'
        .on 'dragmove', =>
          @line.scaleY(@line.scaleY() - @controls.maxCirc.y() + @line.y())
          @line.y(@controls.maxCirc.y())
          @controls.maxCirc.x(@line.x() - 40)
          @lineSize @line.scaleY()
          @lineY @line.y()
          @resetMarks()
        @controls.minCirc = ImageCircle
          size: 20
          image: 'res/down.svg'
          x: @line.x() - 40
          y: @line.y() + @line.scaleY()
          tooltip: 'Ziehen zum verschieben'
        .on 'dragmove', =>
          @line.scaleY(@controls.minCirc.y() - @line.y())
          @controls.minCirc.x(@line.x() - 40)
          @lineSize @line.scaleY()
          @resetMarks()
        Layers.AXES.add(@controls[c]) for c of @controls
      else
        @controls[c].remove() for c of @controls
      Layers.AXES.draw()

  getLine: =>
    @line = new Kinetic.Rect
      fill: Colors.primary
      width: 2
      height: 1
      draggable: yes
      scaleY: STAGE.height() - 100
      x: 50
      y: 50
      hitFunc: (context) ->
        context.beginPath()
        context.rect(-10, 0, 20, 1)
        context.closePath()
        context.fillStrokeShape(@)
    .on 'dragmove', =>
      @lineX @line.x()
      @lineY @line.y()
      if @isEditing()
        @controls.maxCirc.x(@lineX() - 40).y(@lineY())
        @controls.minCirc.x(@lineX() - 40).y(@lineY() + @lineSize())
    .on 'mouseenter', ->
      $('body').css('cursor', 'move')
    .on 'mouseleave', =>
      $('body').css('cursor', '')
    .on 'click', =>
      @isEditing(!@isEditing())

    @lineSize STAGE.height() - 100
    return @line

  createMarks: =>
    for mark in @getMarks()
      a = new Kinetic.Line
        points: [0, 0, 10, 0]
        stroke: Colors.primary
        strokeWidth: 1
        draggable: no
        x: @line.x() - 5
        y: mark.px
      txt = new Kinetic.Text
        text: mark.val.toFixed(2)
        fontSize: 10
        fontFamily: 'sans-serif'
        fill: Colors.primary
      txt.x @line.x() - txt.getTextWidth() - 7
      txt.y mark.px - txt.getTextHeight() / 2
      @axis.add(a).add(txt)
      @marks.push a
      @marks.push txt
    Layers.AXES.draw()

  #source: http://www.ibrtses.com/delphi/dmcs.html
  transformToValue: (y) =>
    if @type() is "linear"
      return (@maxVal() - @minVal()) / @lineSize() * (@lineSize() - y + @lineY()) + @minVal()
    else if @type() is "logarithmic"
      @minVal() * Math.exp(((@lineSize() - y + @lineY()) / @lineSize()) * Math.log(@maxVal() / @minVal()) / Math.log(Math.E))
    else
      console.error "Unknown axis type"

  transform: (y) =>
    if @type() is "linear"
      return @lineY() + @lineSize() - @lineSize() / (@maxVal() - @minVal()) * (y - @minVal())
    else if @type() is "logarithmic"
      return @lineY() + @lineSize() - Math.round(Math.log(y / @minVal()) / Math.log(@maxVal() / @minVal()) * @lineSize())
    else
      console.error "Unknown axis type"

  valueAt: (x, y) =>
    if @type() is 'linear'
      return @transformToValue y
    if @type() is 'logarithmic'
      return @transformToValue y