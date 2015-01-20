#Code for axes
class Axis extends Observable
  constructor: ->
    super()
    @name = observable('').subscribe => @notifyObservers(yes)
    @minVal = observable(0).subscribe(@resetMarks)
    @maxVal = observable(100).subscribe(@resetMarks)
    @interval = observable(10).subscribe(@resetMarks)
    @type = observable("linear").subscribe (v) =>
      if v is "logarithmic" and @minVal() is 0
        @minVal(0.1)
      @resetMarks()
    @axisMode = observable('').subscribe (v) =>
      @resetMarks()

    @marks = []
    @position = observable()
    @subscribe GUI.updateAllValues
    @controls = {}
    @isEditing = observable(no)
    @isEditing.subscribe (v) =>
      if v
        deselectAllExcept(@)
      GUI.selectedAxis(if v then @ else null)
    Layers.AXES.add @axis = new Kinetic.Group

    @axis.add(@line = @getLine()).draw()

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
    @position.subscribe (v) =>
      @controls.minCirc?.y(v.y + 40).x(v.x)
      @controls.maxCirc?.y(v.y + 40).x(v.x + @line.scaleX())
      @resetMarks()
      Layers.AXES.draw()
    @position({x: 50, y: 50})

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
            @resetMarks()
            @notifyObservers(yes)
        @controls.maxCirc = ImageCircle
          size: 20
          image: 'res/right.svg'
          x: @line.x() + @line.scaleX()
          y: @line.y() + 40
          tooltip: 'Ziehen zum verschieben'
        .on 'dragmove', =>
            @line.scaleX(@controls.maxCirc.x() - @line.x())
            @controls.maxCirc.y(@line.y() + 40)
            @resetMarks()
            @notifyObservers(yes)
        Layers.AXES.add(@controls[c]) for c of @controls
      else
        @controls[c].remove() for c of @controls
      Layers.AXES.draw()

  getLine: =>
    @line = new Kinetic.Rect
      fill: 'red'
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
        @position({x: @line.x(), y: @line.y()})
        @notifyObservers(yes)
    .on 'mouseenter', ->
        $('body').css('cursor', 'move')
    .on 'mouseleave', =>
        $('body').css('cursor', '')
    .on 'click', =>
        @isEditing(!@isEditing())

    @createMarks()

    return @line

  lineSize: =>
    @line.scaleX()
  lineOffset: =>
    @line.x()

  createMarks: =>
    for mark in @getMarks()
      a = new Kinetic.Line
        points: [0, 0, 0, 10]
        stroke: 'red'
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
        fill: 'gray'
      @axis.add(a).add(txt)
      @marks.push a
      @marks.push txt
    Layers.AXES.draw()

  #source: http://www.ibrtses.com/delphi/dmcs.html
  transformToValue: (x) =>
    if @type() is "linear"
      return (@maxVal() - @minVal()) / @line.scaleX() * (x - @line.x()) + @minVal()
    else if @type() is "logarithmic"
      return @minVal() * Math.exp(((x - @line.x()) / @line.scaleX()) * Math.log(@maxVal() / @minVal()) / Math.log(Math.E))
    else
      console.error "Unknown axis type"

  transform: (x) =>
    if @type() is "linear"
      console.log "linear"
      return @line.x() + (@line.scaleX() / (@maxVal() - @minVal())) * (x - @minVal())
    else if @type() is "logarithmic"
      return @line.x() + Math.round(Math.log(x / @minVal()) / Math.log(@maxVal() / @minVal()) * @line.scaleX())
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
    @position.subscribe (v) =>
      @controls.minCirc?.x(v.x - 40).y(v.y + @line.scaleY())
      @controls.maxCirc?.x(v.x - 40).y(v.y)
      @resetMarks()
      Layers.AXES.draw()
    @position({x: 50, y: 50})

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
            @resetMarks()
            @notifyObservers(yes)
        @controls.minCirc = ImageCircle
          size: 20
          image: 'res/down.svg'
          x: @line.x() - 40
          y: @line.y() + @line.scaleY()
          tooltip: 'Ziehen zum verschieben'
        .on 'dragmove', =>
            @line.scaleY(@controls.minCirc.y() - @line.y())
            @controls.minCirc.x(@line.x() - 40)
            @resetMarks()
            @notifyObservers(yes)
        Layers.AXES.add(@controls[c]) for c of @controls
      else
        @controls[c].remove() for c of @controls
      Layers.AXES.draw()

  getLine: =>
    @line = new Kinetic.Rect
      fill: 'red'
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
        @position({x: @line.x(), y: @line.y()})
        @notifyObservers(yes)
    .on 'mouseenter', ->
        $('body').css('cursor', 'move')
    .on 'mouseleave', =>
        $('body').css('cursor', '')
    .on 'click', =>
        @isEditing(!@isEditing())

    @createMarks()

    return @line

  lineSize: =>
    @line.scaleY()
  lineOffset: =>
    @line.y()

  createMarks: =>
    for mark in @getMarks()
      a = new Kinetic.Line
        points: [0, 0, 10, 0]
        stroke: 'red'
        strokeWidth: 1
        draggable: no
        x: @line.x() - 5
        y: mark.px
      txt = new Kinetic.Text
        x: @line.x() - 25
        y: mark.px - 4
        text: mark.val.toFixed(2)
        fontSize: 10
        fontFamily: 'sans-serif'
        fill: 'gray'
      @axis.add(a).add(txt)
      @marks.push a
      @marks.push txt
    Layers.AXES.draw()

  #source: http://www.ibrtses.com/delphi/dmcs.html
  transformToValue: (y) =>
    if @type() is "linear"
      return (@maxVal() - @minVal()) / @line.scaleY() * (@line.scaleY() - y + @line.y()) + @minVal()
    else if @type() is "logarithmic"
      @minVal() * Math.exp(((@line.scaleY() - y + @line.y()) / @line.scaleY()) * Math.log(@maxVal() / @minVal()) / Math.log(Math.E))
    else
      console.error "Unknown axis type"

  transform: (y) =>
    if @type() is "linear"
      return @line.y() + @line.scaleY() - @line.scaleY() / (@maxVal() - @minVal()) * (y - @minVal())
    else if @type() is "logarithmic"
      return @line.y() + @line.scaleY() - Math.round(Math.log(y / @minVal()) / Math.log(@maxVal() / @minVal()) * @line.scaleY())
    else
      console.error "Unknown axis type"

  valueAt: (x, y) =>
    if @type() is 'linear'
      return @transformToValue y
    if @type() is 'logarithmic'
      return @transformToValue y