# Code for axes
class Axis
  constructor: (@scale = 10) ->
    @minVal = 0.1
    @maxVal = 100
    @marks = []

    AXES.add(@line = @getLine()).draw()

class HorizontalAxis extends Axis
  getLine: =>
    @lineWidth = STAGE.width() - 100
    @linePos = 50
    @line = new Kinetic.Line
      points: [0, 0, STAGE.width() - 100, 0]
      stroke: 'red'
      strokeWidth: 2
      draggable: yes
      x: 50
      y: 50
    .on 'dragmove', =>
      @line.x(50)
      console.log 'dragmove'
      mark.remove() for mark in @marks
      @createMarks()
      STAGE.draw()
    .on 'mouseenter', -> $('body').css('cursor', 'row-resize')
    .on 'mouseleave', -> $('body').css('cursor', '')

  createMarks: =>
    last = 1
    v = @minVal
    f = Math.pow(10, Math.floor(Math.log(v)) + 2)
    console.log f
    i = 0
    pos = 0
    while pos < @lineWidth + @linePos
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
  transformToValue: (x) => @minVal * Math.exp(((x - @linePos) / @lineWidth) * Math.log(@maxVal / @minVal) / Math.log(Math.E))
  transform: (x) => @linePos + Math.round(Math.log(x / @minVal) / Math.log(@maxVal / @minVal) * @lineWidth)

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