# Code for axes
class Axis
  constructor: () ->
    @minVal = observable(0.1).bind(@resetMarks)
    @maxVal = observable(100).bind(@resetMarks)
    @marks = []
    @position = observable()
    @controls = {}
    @isEditing = observable(no)

    AXES.add @axis = new Kinetic.Group

    @axis.add(@line = @getLine()).draw()

  resetMarks: =>
    mark.remove() for mark in @marks
    @createMarks()

class HorizontalAxis extends Axis
  constructor: ->
    super()
    @position.bind (v) =>
      @controls.minCirc?.y(v.y + 40).x(v.x)
      @controls.maxCirc?.y(v.y + 40).x(v.x + @line.scaleX())
      @resetMarks()
      AXES.draw()
    @position({x: 50, y: 50})

    @isEditing.bind (v) =>
      if v
        @controls.minCirc = ImageCircle
          size: 20
          image: 'res/left.svg'
          x: @line.x()
          y: @line.y() + 40
        .on 'dragmove', =>
            @line.scaleX(@line.scaleX() - @controls.minCirc.x() + @line.x())
            @line.x(@controls.minCirc.x())
            @controls.minCirc.y(@line.y() + 40)
            @resetMarks()
        @controls.maxCirc = ImageCircle
          size: 20
          image: 'res/right.svg'
          x: @line.x() + @line.scaleX()
          y: @line.y() + 40
        .on 'dragmove', =>
            @line.scaleX(@controls.maxCirc.x() - @line.x())
            @controls.maxCirc.y(@line.y() + 40)
            @resetMarks()
        AXES.add(@controls[c]) for c of @controls
      else
        @controls[c].remove() for c of @controls
      AXES.draw()

  getLine: =>
    @line = new Kinetic.Line
      points: [0, 0, 1, 0]
      stroke: 'red'
      strokeWidth: 2
      draggable: yes
      scaleX: STAGE.width() - 100
      x: 50
      y: 50
    .on 'dragmove', =>
      console.log 'dragmove'
      @position({x: @line.x(), y: @line.y()})
    .on 'mouseenter', -> $('body').css('cursor', 'move')
    .on 'mouseleave', -> $('body').css('cursor', '')
    .on 'click', => @isEditing(!@isEditing())

    @createMarks()

    return @line

  createMarks: =>
    v = @minVal()
    f = Math.pow(10, Math.floor(Math.log(v)) + 2)
    console.log f
    i = 0
    pos = 0
    while pos < @line.scaleX() + @line.x()
      a = new Kinetic.Line
        points: [0, 0, 0, 10]
        stroke: 'red'
        strokeWidth: 1
        draggable: no
        x: pos = @transform v
        y: @line.y() - 5
      txt = new Kinetic.Text
        x: pos
        y: @line.y() + 5
        text: Math.round(v*10)/10
        fontSize: 10
        fontFamily: 'sans-serif'
        fill: 'gray'
      AXES.add(a).add(txt)
      @marks.push a
      @marks.push txt
      v += f
      i++
      if i == 9
        i = 0
        f *= 10

  #source: http://www.ibrtses.com/delphi/dmcs.html
  transformToValue: (x) => @minVal() * Math.exp(((x - @line.x()) / @line.scaleX()) * Math.log(@maxVal() / @minVal()) / Math.log(Math.E))
  transform: (x) => @line.x() + Math.round(Math.log(x / @minVal()) / Math.log(@maxVal() / @minVal()) * @line.scaleX())

class VerticalAxis extends Axis
  constructor: ->
    super()
    @position.bind (v) =>
      @controls.minCirc?.x(v.x - 40).y(v.y)
      @controls.maxCirc?.x(v.x - 40).y(v.y + @line.scaleY())
      @resetMarks()
      AXES.draw()
    @position({x: 50, y: 50})

    @isEditing.bind (v) =>
      if v
        @controls.minCirc = ImageCircle
          size: 20
          image: 'res/left.svg'
          x: @line.x() - 40
          y: @line.y()
        .on 'dragmove', =>
            @line.scaleY(@line.scaleY() - @controls.minCirc.y() + @line.y())
            @line.y(@controls.minCirc.y())
            @controls.minCirc.x(@line.x() - 40)
            @resetMarks()
        @controls.maxCirc = ImageCircle
          size: 20
          image: 'res/right.svg'
          x: @line.x() - 40
          y: @line.y() + @line.scaleY()
        .on 'dragmove', =>
            @line.scaleY(@controls.maxCirc.y() - @line.y())
            @controls.maxCirc.x(@line.x() - 40)
            @resetMarks()
        AXES.add(@controls[c]) for c of @controls
      else
        @controls[c].remove() for c of @controls
      AXES.draw()

  getLine: =>
    @line = new Kinetic.Line
      points: [0, 0, 0, 1]
      scaleY: STAGE.height() - 100
      stroke: 'red'
      strokeWidth: 2
      draggable: yes
      x: 50
      y: 50
    .on 'dragmove', =>
      console.log 'dragmove'
      @position({x: @line.x(), y: @line.y()})
    .on 'mouseenter', -> $('body').css('cursor', 'move')
    .on 'mouseleave', -> $('body').css('cursor', '')
    .on 'click', => @isEditing(!@isEditing())

    @createMarks()

    return @line

  createMarks: =>
    v = @minVal()
    f = Math.pow(10, Math.floor(Math.log(v)) + 2)
    console.log f
    i = 0
    pos = Infinity
    while pos > @line.y()
      a = new Kinetic.Line
        points: [0, 0, 10, 0]
        stroke: 'red'
        strokeWidth: 1
        draggable: no
        x: @line.x() - 5
        y: pos = @transform v
      txt = new Kinetic.Text
        x: @line.x() - 25 #TODO calculate these numbers dynamically
        y: pos - 3
        text: Math.round(v*10)/10
        fontSize: 10
        fontFamily: 'sans-serif'
        fill: 'gray'
      AXES.add(a).add(txt)
      @marks.push a
      @marks.push txt
      v += f
      i++
      if i == 9
        i = 0
        f *= 10

  #source: http://www.ibrtses.com/delphi/dmcs.html
  transformToValue: (y) => @minVal() * Math.exp(((y - @line.y()) / @line.scaleY()) * Math.log(@maxVal() / @minVal()) / Math.log(Math.E))
  transform: (y) => @line.y() + @line.scaleY() - Math.round(Math.log(y / @minVal()) / Math.log(@maxVal() / @minVal()) * @line.scaleY())