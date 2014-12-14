# Code for axes
class Axis
  constructor: (@scale = 10) ->
    @minVal = observable(0.1)
    @maxVal = observable(100)
    @marks = []
    @position = observable()
    @controls = {}

    AXES.add(@line = @getLine()).draw()

class HorizontalAxis extends Axis
  constructor: ->
    super()
    @isEditing = no
    @position({x: 50, y: 50})
    @position.bind (v) =>
      @controls.minCirc?.y(v.y + 40).x(v.x)
      @controls.maxCirc?.y(v.y + 40).x(v.x + @line.scaleX())
      @resetMarks()
      AXES.draw()
    @minVal.bind =>
      @resetMarks()
      AXES.draw()
    @maxVal.bind =>
      @resetMarks()
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
    .on 'click', =>
      if @isEditing
        @controls[c].remove() for c of @controls
      else
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

      AXES.draw()
      @isEditing = !@isEditing

    @createMarks()

    return @line

  resetMarks: =>
    mark.remove() for mark in @marks
    @createMarks()

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
        x:  pos = @transform v
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
  getLine: ->
    new Kinetic.Line
      points: [0, 0, 0, STAGE.height() - 100]
      stroke: 'red'
      strokeWidth: 5
      draggable: yes
      x: 50
      y: 50
    .on 'dragmove', =>
        @line.y(50)
        console.log 'dragmove'
    .on 'mouseenter', -> $('body').css('cursor', 'col-resize')
    .on 'mouseleave', -> $('body').css('cursor', '')